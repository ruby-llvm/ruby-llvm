/*
 * Extended bindings for LLVM.
 */

#include <llvm-c/Core.h>
#include <llvm/GlobalValue.h>
#include <llvm/Support/DynamicLibrary.h>
#include <llvm/Type.h>

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

  void LLVMDumpType(LLVMTypeRef type) {
    unwrap<Type>(type)->dump();
  }
}

