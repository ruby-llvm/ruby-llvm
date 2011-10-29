require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :LLVMAddTargetData, [:pointer, :pointer], :void
  end
end
