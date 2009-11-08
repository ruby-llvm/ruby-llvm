require 'llvm'
require 'llvm/core'

module LLVM
  module C
    ffi_lib 'LLVMTarget'
    attach_function :LLVMAddTargetData, [:pointer, :pointer], :void
  end
end
