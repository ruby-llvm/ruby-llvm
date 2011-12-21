/*
 * Extended bindings for LLVM.
 */

#include <llvm/Support/DynamicLibrary.h>

extern "C" {
  int LLVMLoadLibraryPermanently(const char* filename) {
    return llvm::sys::DynamicLibrary::LoadLibraryPermanently(filename);
  }
}

