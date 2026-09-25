/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/IR/Attributes.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Value.h>
#include <llvm/IR/Type.h>
#include <llvm-c/Core.h>
#include <string>

// Allocates a caller-owned copy of s, to be released with LLVMDisposeMessage.
//
// Uses LLVMCreateMessage rather than strdup so the allocation happens inside
// LLVM's own module, pairing with the free() that LLVMDisposeMessage performs
// there. Every string this file hands back is declared `char *` (not `const
// char *`) and goes through here, so ownership is stated in one place.
static char* owned_message(const std::string &s) {
  return LLVMCreateMessage(s.c_str());
}

#ifdef _WIN32
#define LLVM_SUPPORT_API __declspec(dllexport)
#else
#define LLVM_SUPPORT_API
#endif

extern "C" {
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
  LLVM_SUPPORT_API char* LLVMGetAttributeAsString(LLVMAttributeRef A) {
    return owned_message(llvm::unwrap(A).getAsString());
  }

  // void Type::print(raw_ostream &O, bool IsForDebug = false,
  //                  bool NoDetails = false) const
  // https://llvm.org/doxygen/classllvm_1_1Type.html
  //
  // As LLVMPrintTypeToString, but with IsForDebug=true, matching what
  // LLVMDumpType writes to stderr. As of LLVM 21 this renders identically to
  // IsForDebug=false for every type kind; it exists so the API matches Module
  // and Value, and so a future divergence is picked up rather than missed.
  // String must be disposed with LLVMDisposeMessage.
  LLVM_SUPPORT_API char* LLVMPrintTypeToStringDebug(LLVMTypeRef Ty) {
    std::string buf;
    llvm::raw_string_ostream os(buf);
    if (llvm::unwrap(Ty))
      llvm::unwrap(Ty)->print(os, /*IsForDebug=*/true);
    else
      os << "Printing <null> Type";
    os.flush();
    return owned_message(buf);
  }

  // void Value::print(raw_ostream &O, bool IsForDebug = false) const
  // https://llvm.org/doxygen/classllvm_1_1Value.html
  //
  // As LLVMPrintValueToString, but with IsForDebug=true, matching what
  // LLVMDumpValue writes to stderr. Only affects function declarations, whose
  // parameters LLVMPrintValueToString omits.
  // String must be disposed with LLVMDisposeMessage.
  LLVM_SUPPORT_API char* LLVMPrintValueToStringDebug(LLVMValueRef V) {
    std::string buf;
    llvm::raw_string_ostream os(buf);
    if (llvm::unwrap(V))
      llvm::unwrap(V)->print(os, /*IsForDebug=*/true);
    else
      os << "Printing <null> Value";
    os.flush();
    return owned_message(buf);
  }

  // void Module::print(raw_ostream &OS, AssemblyAnnotationWriter *AAW,
  //                    bool ShouldPreserveUseListOrder = false,
  //                    bool IsForDebug = false) const
  // https://llvm.org/doxygen/classllvm_1_1Module.html
  //
  // As LLVMPrintModuleToString, but with IsForDebug=true, matching what
  // LLVMDumpModule writes to stderr. Only affects declarations, whose
  // parameters LLVMPrintModuleToString omits.
  // String must be disposed with LLVMDisposeMessage.
  LLVM_SUPPORT_API char* LLVMPrintModuleToStringDebug(LLVMModuleRef M) {
    std::string buf;
    llvm::raw_string_ostream os(buf);
    llvm::unwrap(M)->print(os, nullptr,
                           /*ShouldPreserveUseListOrder=*/false,
                           /*IsForDebug=*/true);
    os.flush();
    return owned_message(buf);
  }
}

