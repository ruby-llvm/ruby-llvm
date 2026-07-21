/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/IR/Attributes.h>
#ifdef _WIN32
#include <io.h>
#include <fcntl.h>
#include <cstdlib>
#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif
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

  // Flush errs() and clear its error flag before Ruby closes fd 2.
  // errs() is a C++ function-local static; its destructor calls
  // report_fatal_error (exit 1) if flush fails because fd 2 is already closed.
  // On Windows, also redirect fd 2 to NUL so the destructor's flush() succeeds.
  LLVM_SUPPORT_API void LLVMFlushAndClearErrs() {
    llvm::errs().flush();
    static_cast<llvm::raw_fd_ostream &>(llvm::errs()).clear_error();
#ifdef _WIN32
    int nul = _open("NUL", _O_WRONLY);
    if (nul >= 0) {
      _dup2(nul, STDERR_FILENO);
      _close(nul);
    }
#endif
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

