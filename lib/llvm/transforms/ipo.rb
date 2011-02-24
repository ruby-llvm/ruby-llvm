# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'

module LLVM
  module C
    attach_function :LLVMAddGlobalDCEPass, [:pointer], :void
  end

  class PassManager
    def gdce!
      C.LLVMAddGlobalDCEPass(self)
    end
  end
end
