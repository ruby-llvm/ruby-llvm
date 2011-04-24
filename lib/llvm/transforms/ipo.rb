# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :LLVMAddGlobalDCEPass, [:pointer], :void
  end

  class PassManager
    # @LLVMpass gdce
    def gdce!
      C.LLVMAddGlobalDCEPass(self)
    end
  end
end
