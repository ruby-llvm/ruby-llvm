/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/IR/Attributes.h>
#include <cstdlib>

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

  // Clears errs() error flag just before its C++ destructor fires.
  // Registered via std::atexit after errs() is first used, so it runs before
  // errs() destructs (LIFO). Uses a stored pointer — no re-initialization risk.
  static llvm::raw_fd_ostream *g_errs = nullptr;
  static void clear_errs_at_exit() {
    if (g_errs) g_errs->clear_error();
  }

  // Called from Ruby's at_exit. Flushes and clears errs() now, and registers
  // a C atexit to clear it again after Ruby VM teardown (GC finalizers may
  // write to errs() between the Ruby hook and the C++ destructor).
  // Returns 1 if errs() had an error at call time, 0 otherwise.
  LLVM_SUPPORT_API int LLVMFlushAndClearErrs() {
    llvm::errs().flush();
    auto &OS = static_cast<llvm::raw_fd_ostream &>(llvm::errs());
    int had_error = OS.has_error() ? 1 : 0;
    OS.clear_error();
    if (!g_errs) {
      g_errs = &OS;
      std::atexit(clear_errs_at_exit);
    }
    return had_error;
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

  LLVM_SUPPORT_API void LLVMInitializeNativeTarget() {
    llvm::InitializeNativeTarget();
  }

  LLVM_SUPPORT_API void LLVMInitializeNativeAsmPrinter() {
    llvm::InitializeNativeTargetAsmPrinter();
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
