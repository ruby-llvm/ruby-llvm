# LLVM errs() / LLVMShutdown Windows Teardown

## Adversarial claim verification

- `errs()` is a ManagedStatic — **REFUTED** (2 independent source fetches of raw_ostream.cpp confirm it's a function-local static in all recent LLVM)
- LLVMShutdown destroys `errs()` — **REFUTED** (`errs()` is not registered as a ManagedStatic, so llvm_shutdown's ManagedStatic chain doesn't touch it)
- Destructor flushes and can call `report_fatal_error` — **CONFIRMED** (exact destructor code retrieved from mirror; confirmed by issues #48672, Discourse thread)
- Windows DLL context + invalid FD → exit failure — **CONFIRMED** (Discourse thread, issue #48672, D53968)
- LLVMShutdown is safe to call in DLL context — **REFUTED** (PR #166054, issue #154361, D53968 all document Windows DLL + shutdown hazards)

---

## Factual correction on the mechanism

The premise that `errs()` is a ManagedStatic is **incorrect for all LLVM versions shipped in the last several years**. In current and recent LLVM, `errs()` is a **function-scope local static**, not a ManagedStatic:

```cpp
// llvm/lib/Support/raw_ostream.cpp
raw_ostream &llvm::errs() {
  static raw_fd_ostream S(STDERR_FILENO, false, true);
  return S;
}
```

This means `LLVMShutdown()`/`llvm_shutdown()` does **not** destroy `errs()` through the ManagedStatic chain. The stream is destroyed later, during normal C++ static destructor unwinding at program exit. The `ShouldClose = false` guard (set whenever `FD <= STDERR_FILENO`) means its destructor will not close FD 2 — but it **will** call `flush()`, and if that flush fails, the destructor fires `report_fatal_error("IO failure on output stream: " + error().message(), false)`, which calls `exit(1)` internally.

## The actual Windows failure path

The failure does happen; it just has a slightly different trigger than stated. Two confirmed paths:

**Path A — Windows DLL / no stderr FD (the most-documented case):**
In GUI apps or DLL host processes on Windows, FDs 1 and 2 are often not opened. When LLVM code calls `errs()`, the write fails silently but sets an internal error flag on the stream. When the function-local static destructor fires (at DLL unload or process exit), `has_error()` is true, so the destructor calls `report_fatal_error`, which calls `exit(1)`. This is exactly "intermittent exit code 1 with no user-visible message" in hosts that redirect or discard stderr.

- Documented in: [LLVM Discourse — Dealing with llvm::errs() and friends in dynamic libs on Windows](https://discourse.llvm.org/t/dealing-with-llvm-errs-and-friends-in-dynamic-libs-on-windows/49713)
- No single GitHub issue; treated as a design-level concern by LLVM developers.

**Path B — Broken pipe / stale console handle:**
On Windows, when the console HANDLE backing stderr becomes invalid (process teardown order, or a pipe reader exiting early), a write via `WriteConsoleW` or the fallback `::write` returns an error. The error flag accumulates. Destructor fires `report_fatal_error`. This matches issue [#48672](https://github.com/llvm/llvm-project/issues/48672) (stdout/pipe teardown on Windows → "IO failure on output stream: invalid argument") and the mailing-list bug [#41968](https://github.com/llvm/llvm-project/issues/41968) (lld-link, bad file descriptor on networked drives).

There is **no single filed LLVM bug** titled "errs() + console HANDLE + LLVMShutdown". The console teardown angle is mechanically real but underdocumented — it collapses into the general "raw_fd_ostream destructor calls report_fatal_error when flush fails."

## Known/filed issues

| Issue | Description | Platform | Status |
|-------|-------------|----------|--------|
| [Discourse #49713](https://discourse.llvm.org/t/dealing-with-llvm-errs-and-friends-in-dynamic-libs-on-windows/49713) | errs()/outs() destructor kills process in Windows DLL contexts | Windows | No patch; design discussion |
| [#48672](https://github.com/llvm/llvm-project/issues/48672) | raw_fd_ostream destructor fatal error when pipe reader exits early | Windows | Identified; fix direction known |
| [#41968](https://github.com/llvm/llvm-project/issues/41968) | lld-link "IO failure on output stream: bad file descriptor" on networked drives | Windows | Open |
| [#154361](https://github.com/llvm/llvm-project/issues/154361) | libclang.dll crashes on exit (FlsAlloc dangling callbacks) | Windows DLL | Fixed PR #171465 |
| [PR #166054](https://github.com/llvm/llvm-project/pull/166054) | ThreadPoolExecutor deadlock when LLVM built as Windows DLL + llvm_shutdown | Windows DLL | Merged Jan 2026 |
| [#60361](https://github.com/llvm/llvm-project/issues/60361) | Abort/segfault on exit after LLVM 15 ManagedStatic removal broke destruction order | Linux/Mesa | Workaround: revert to ManagedStatic |
| [D129132](https://reviews.llvm.org/D129132) | Remove ManagedStatic, make llvm_shutdown() a no-op | All | In progress (LLVM 16+) |

## Root cause per LLVM developers

From the Discourse thread: LLVM libraries are not supposed to write to `errs()` without an explicit user request. The `raw_fd_ostream` destructor's `report_fatal_error` call on flush failure was designed for CLI tools where stderr is always valid. In DLL/plugin contexts on Windows, this design assumption breaks. LLVM developer Eli Friedman characterized any unintended output to `errs()` in library contexts as a bug in the calling code or LLVM internals, rather than a bug in the stream teardown itself.

The broader picture: `ManagedStatic` and `llvm_shutdown` are being **actively retired** ([FOSDEM 2023 talk "Eliminating ManagedStatic and llvm_shutdown"](https://archive.fosdem.org/2023/schedule/event/llvmglobalstate/); [D129132](https://reviews.llvm.org/D129132)). The motivating reason is exactly this class of problem: LLVM used as a shared library in plugin-like settings (OpenGL/Vulkan drivers, language runtimes) where the host process controls shutdown and calling `llvm_shutdown` at the right time is unreliable or unsafe.

## Is LLVMShutdown recommended in DLL contexts on Windows?

**No.** Multiple documented bugs show it is hazardous:
- Deadlock in `ThreadPoolExecutor` when LLVM is a DLL (PR #166054, fixed; same class of bug existed with D53968 for mingw)
- `FlsAlloc` callbacks becoming dangling after DLL unload (Issue #154361)
- Destruction order issues when statics are mixed with/without ManagedStatic (Issue #60361)

The direction since LLVM 16 is: `llvm_shutdown` is a no-op stub. Don't rely on it for cleanup.

## What other language bindings do

- **inkwell (Rust)**: `shutdown_llvm()` is documented as "very unsafe" and "might not even be absolutely necessary." No Windows-specific workaround; callers are warned to not touch LLVM data afterward.
- **llvmlite (Python/Numba)**: Avoids raw LLVM shutdown sequence issues by managing object lifetimes in Python; [issue #350](https://github.com/numba/llvmlite/issues/350) is about Python teardown warning, not Windows console specifically.
- **PostgreSQL JIT**: Explicitly skips `llvm_shutdown` when LLVM itself triggered an error (unsafe to call back into LLVM after failure).
- **Mesa (GPU drivers)**: Hit the LLVM 15 ManagedStatic removal hard (Issue #60361); workaround was reverting affected statics to ManagedStatic.

## Actionable workarounds (ranked by invasiveness)

1. **Don't call `LLVMShutdown()`** — In modern LLVM it is a no-op or near-no-op. Inkwell explicitly documents this as acceptable. Skip it, especially in DLL contexts.

2. **Call `llvm::errs().clear_error()` before exit/unload** — Suppresses the fatal error in the destructor. The Discourse thread shows this as the quick-fix pattern:
   ```cpp
   if (auto *fds = llvm::dyn_cast<llvm::raw_fd_ostream>(&llvm::errs()))
       fds->clear_error();
   ```

3. **Ensure FDs 1 and 2 are always valid** — Redirect them to NUL (`freopen("NUL", "w", stderr)`) before loading LLVM in DLL contexts where the host doesn't open standard handles.

4. **Use `LLVMContext::setDiagnosticHandler()`** — Prevents LLVM internals from writing to `errs()` unexpectedly, reducing the chance an error accumulates on the stream.

5. **Target LLVM 16+** — The ManagedStatic/llvm_shutdown deprecation removes the entire lifecycle management issue. `errs()` was already a function-local static before that, but the broader shutdown machinery became much safer.

## Options for ruby-llvm

1. **C extension** — add `llvm_flush_and_clear_errs()` to `ext/ruby-llvm-support/support.cpp`, expose it via FFI, call it in `at_exit` before Ruby closes fd 2. Proper fix, requires recompile.

2. **Skip `test_dump` entirely on mswin** — `mod.dump` is the only thing that triggers `errs()` in tests. If we never call it, `errs()` is never initialized and the destructor is a no-op. Fragile if other LLVM calls start using `errs()`.

3. **Remove `at_exit { LLVM::C.shutdown }`** — it's a no-op in modern LLVM anyway (`errs()` is not a ManagedStatic). Won't fix the crash but cleans up the code.
