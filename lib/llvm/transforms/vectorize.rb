# frozen_string_literal: true

require 'llvm'
require 'llvm/core'
require 'llvm/transforms/vectorize_ffi'

module LLVM
  class PassManager
    # @LLVMpass bb_vectorize
    def bb_vectorize!
      warn('bb_vectorize! / LLVMAddBBVectorizePass was removed from LLVM - replace with slp_vectorize!')
      slp_vectorize!
    end

    # @LLVMpass loop_vectorize
    # /** See llvm::createLoopVectorizePass function. */
    # void LLVMAddLoopVectorizePass(LLVMPassManagerRef PM);
    def loop_vectorize!
      C.add_loop_vectorize_pass(self)
    end

    # @LLVMpass slp_vectorize
    # /** See llvm::createSLPVectorizerPass function. */
    # void LLVMAddSLPVectorizePass(LLVMPassManagerRef PM);
    def slp_vectorize!
      C.add_slp_vectorize_pass(self)
    end
  end
end
