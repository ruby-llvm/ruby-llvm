# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :LLVMAddGlobalDCEPass, [:pointer], :void
    attach_function :LLVMAddFunctionInliningPass, [:pointer], :void
  end

  class PassManager
    # @LLVMpass gdce
    def gdce!
      C.LLVMAddGlobalDCEPass(self)
    end
    
    # @LLVMpass inline
    def inline!
      C.LLVMAddFunctionInliningPass(self)
    end
  end
end
