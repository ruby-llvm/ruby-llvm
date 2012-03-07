/*
 * Extended bindings for LLVM.
 */

#include <llvm/ADT/StringRef.h>
#include <llvm/Support/DynamicLibrary.h>

extern "C" {
  int LLVMLoadLibraryPermanently(const char* filename) {
    return llvm::sys::DynamicLibrary::LoadLibraryPermanently(filename);
  }
}

