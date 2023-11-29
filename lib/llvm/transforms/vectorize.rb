# frozen_string_literal: true

require 'llvm'
require 'llvm/core'

module LLVM
  class PassManager
    # @LLVMpass bb_vectorize
    def bb_vectorize!
      raise DeprecationError
    end

    # @LLVMpass loop_vectorize
    # /** See llvm::createLoopVectorizePass function. */
    # void LLVMAddLoopVectorizePass(LLVMPassManagerRef PM);
    def loop_vectorize!
      raise DeprecationError
    end

    # @LLVMpass slp_vectorize
    # /** See llvm::createSLPVectorizerPass function. */
    # void LLVMAddSLPVectorizePass(LLVMPassManagerRef PM);
    def slp_vectorize!
      raise DeprecationError
    end
  end
end
