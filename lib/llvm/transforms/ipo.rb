# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'
require 'llvm/transforms/ipo_ffi'

module LLVM
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
