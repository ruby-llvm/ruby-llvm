/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/TargetSelect.h>
#include <llvm/IR/Attributes.h>

extern "C" {
  void LLVMInitializeAllTargetInfos() {
    llvm::InitializeAllTargetInfos();
  }

  void LLVMInitializeAllTargets() {
    llvm::InitializeAllTargets();
  }

  void LLVMInitializeAllTargetMCs() {
    llvm::InitializeAllTargetMCs();
  }

  void LLVMInitializeAllAsmPrinters() {
    llvm::InitializeAllAsmPrinters();
  }

  void LLVMInitializeNativeTarget() {
    llvm::InitializeNativeTarget();
  }

  void LLVMInitializeNativeAsmPrinter() {
    llvm::InitializeNativeTargetAsmPrinter();
  }

  // static StringRef getNameFromAttrKind(Attribute::AttrKind AttrKind)
  // https://llvm.org/doxygen/classllvm_1_1Attribute.html
  const char* LLVMGetEnumAttributeNameForKind(const unsigned KindID) {
    const auto AttrKind = (llvm::Attribute::AttrKind) KindID;
    const auto S = llvm::Attribute::getNameFromAttrKind(AttrKind);
    return S.data();
  }

  // std::string Attribute::getAsString(bool InAttrGrp = false) const
  // https://llvm.org/doxygen/classllvm_1_1Attribute.html
  // string must be disposed with LLVMDisposeMessage
  const char* LLVMGetAttributeAsString(LLVMAttributeRef A) {
    auto S = llvm::unwrap(A).getAsString();
    return strdup(S.c_str());
  }
}

