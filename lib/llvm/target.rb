require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :add_target_data, :LLVMAddTargetData, [:pointer, :pointer], :void
  end
end
