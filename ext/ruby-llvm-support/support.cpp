/*
 * Extended bindings for LLVM.
 */

#include <cstdlib>
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

  const char* LLVMGetEnumAttributeNameForKind(const unsigned KindID) {
    const auto AttrKind = (llvm::Attribute::AttrKind) KindID;
    const auto S = llvm::Attribute::getNameFromAttrKind(AttrKind);
    return S.data();
  }
}

