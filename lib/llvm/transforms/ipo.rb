# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :add_global_dce_pass, :LLVMAddGlobalDCEPass, [:pointer], :void
    attach_function :add_function_inlining_pass, :LLVMAddFunctionInliningPass, [:pointer], :void
  end

  class PassManager
    # @LLVMpass gdce
    def gdce!
      C.add_global_dce_pass(self)
    end
    
    # @LLVMpass inline
    def inline!
      C.add_function_inlining_pass(self)
    end
  end
end
