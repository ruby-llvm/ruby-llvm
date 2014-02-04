/*
 * Extended bindings for LLVM.
 */

#include <llvm-c/Core.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/Support/DynamicLibrary.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>

extern "C" {
  using namespace llvm;

  int LLVMLoadLibraryPermanently(const char* filename) {
    return llvm::sys::DynamicLibrary::LoadLibraryPermanently(filename);
  }

  LLVMBool LLVMHasUnnamedAddr(LLVMValueRef global) {
    return unwrap<GlobalValue>(global)->hasUnnamedAddr();
  }

  void LLVMSetUnnamedAddr(LLVMValueRef global, LLVMBool val) {
    unwrap<GlobalValue>(global)->setUnnamedAddr(val != 0);
  }

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
}

