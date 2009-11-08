require 'ffi'

module LLVM
  module C
    extend ::FFI::Library
    # load required libraries
    ffi_lib 'LLVMSystem'
    ffi_lib 'LLVMSupport'
  end
end
