/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/AutoConvert.h>
#include <llvm/IR/Attributes.h>
#include <llvm/IR/Module.h>
#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

#define STRINGIFY_HELPER(x) #x
#define STRINGIFY(x) STRINGIFY_HELPER(x)

#ifdef _WIN32
#define LLVM_SUPPORT_API __declspec(dllexport)
#else
#define LLVM_SUPPORT_API
#endif

extern "C" {

  LLVM_SUPPORT_API const char * LLVMNativeArch() {
#ifdef LLVM_NATIVE_ARCH
    return STRINGIFY(LLVM_NATIVE_ARCH);
#else
    return nullptr;
#endif
  }

  // Like LLVMDumpModule but avoids the errs() function-local static.
  // On Windows, errs() teardown crashes after Ruby closes fd 2.
  LLVM_SUPPORT_API int LLVMDumpModuleToStderr(LLVMModuleRef M) {
    // Mirror errs(): enable auto-conversion on stderr once (no-op on non-z/OS).
    static std::error_code _ec = llvm::enableAutoConversion(STDERR_FILENO);
    (void)_ec;
    llvm::raw_fd_ostream OS(STDERR_FILENO, /*shouldClose=*/false, /*unbuffered=*/true);
    llvm::unwrap(M)->print(OS, nullptr, /*ShouldPreserveUseListOrder=*/false, /*IsForDebug=*/true);
    bool failed = OS.has_error();
    OS.clear_error();
    return failed ? 1 : 0;
  }

  LLVM_SUPPORT_API void LLVMInitializeAllTargetInfos() {
    llvm::InitializeAllTargetInfos();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllTargets() {
    llvm::InitializeAllTargets();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllTargetMCs() {
    llvm::InitializeAllTargetMCs();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllAsmPrinters() {
    llvm::InitializeAllAsmPrinters();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllAsmParsers() {
    llvm::InitializeAllAsmParsers();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllDisassemblers() {
    llvm::InitializeAllDisassemblers();
  }

  LLVM_SUPPORT_API void LLVMInitializeAllTargetMCAs() {
    llvm::InitializeAllTargetMCAs();
  }

  LLVM_SUPPORT_API void LLVMInitializeNativeTarget() {
    llvm::InitializeNativeTarget();
  }

  LLVM_SUPPORT_API void LLVMInitializeNativeAsmPrinter() {
    llvm::InitializeNativeTargetAsmPrinter();
  }

  LLVM_SUPPORT_API void LLVMInitializeNativeAsmParser() {
    llvm::InitializeNativeTargetAsmParser();
  }

  LLVM_SUPPORT_API void LLVMInitializeNativeDisassembler() {
    llvm::InitializeNativeTargetDisassembler();
  }

  // static StringRef getNameFromAttrKind(Attribute::AttrKind AttrKind)
  // https://llvm.org/doxygen/classllvm_1_1Attribute.html
  LLVM_SUPPORT_API const char* LLVMGetEnumAttributeNameForKind(const unsigned KindID) {
    const auto AttrKind = (llvm::Attribute::AttrKind) KindID;
    const auto S = llvm::Attribute::getNameFromAttrKind(AttrKind);
    return S.data();
  }

  // std::string Attribute::getAsString(bool InAttrGrp = false) const
  // https://llvm.org/doxygen/classllvm_1_1Attribute.html
  // string must be disposed with LLVMDisposeMessage
  LLVM_SUPPORT_API const char* LLVMGetAttributeAsString(LLVMAttributeRef A) {
    auto S = llvm::unwrap(A).getAsString();
    return strdup(S.c_str());
  }
}

