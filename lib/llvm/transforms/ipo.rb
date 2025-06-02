# frozen_string_literal: true
# typed: true

# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'

module LLVM
  class PassManager
    # @LLVMpass arg_promotion
    def arg_promote!
      raise DeprecationError
    end

    # @LLVMpass const_merge
    # /** See llvm::createConstantMergePass function. */
    # void LLVMAddConstantMergePass(LLVMPassManagerRef PM);
    def const_merge!
      raise DeprecationError
    end

    # @LLVMpass mergefunc
    # /** See llvm::createMergeFunctionsPass function. */
    # void LLVMAddMergeFunctionsPass(LLVMPassManagerRef PM);
    def mergefunc!
      raise DeprecationError
    end

    # @LLVMpass called-value-propagation
    # /** See llvm::createCalledValuePropagationPass function. */
    # void LLVMAddCalledValuePropagationPass(LLVMPassManagerRef PM);
    def called_value_propagation!
      raise DeprecationError
    end

    # @LLVMpass dae
    # /** See llvm::createDeadArgEliminationPass function. */
    # void LLVMAddDeadArgEliminationPass(LLVMPassManagerRef PM);
    def dae!
      raise DeprecationError
    end

    # @LLVMpass function_attrs
    # /** See llvm::createFunctionAttrsPass function. */
    # void LLVMAddFunctionAttrsPass(LLVMPassManagerRef PM);
    def fun_attrs!
      raise DeprecationError
    end

    # @LLVMpass inline
    # /** See llvm::createFunctionInliningPass function. */
    # void LLVMAddFunctionInliningPass(LLVMPassManagerRef PM);
    def inline!
      raise DeprecationError
    end

    # @LLVMpass always_inline
    # /** See llvm::createAlwaysInlinerPass function. */
    # void LLVMAddAlwaysInlinerPass(LLVMPassManagerRef PM);
    def always_inline!
      raise DeprecationError
    end

    # @LLVMpass gdce
    # /** See llvm::createGlobalDCEPass function. */
    # void LLVMAddGlobalDCEPass(LLVMPassManagerRef PM);
    def gdce!
      raise DeprecationError
    end

    # @LLVMpass global_opt
    # /** See llvm::createGlobalOptimizerPass function. */
    # void LLVMAddGlobalOptimizerPass(LLVMPassManagerRef PM);
    def global_opt!
      raise DeprecationError
    end

    # @LLVMpass ipcp
    def ipcp!
      raise DeprecationError
    end

    # @LLVMpass prune_eh
    # /** See llvm::createPruneEHPass function. */
    # void LLVMAddPruneEHPass(LLVMPassManagerRef PM);
    def prune_eh!
      raise DeprecationError
    end

    # @LLVMpass ipsccp
    # /** See llvm::createIPSCCPPass function. */
    # void LLVMAddIPSCCPPass(LLVMPassManagerRef PM);
    def ipsccp!
      raise DeprecationError
    end

    # @LLVMpass internalize
    # /** See llvm::createInternalizePass function. */
    # void LLVMAddInternalizePass(LLVMPassManagerRef, unsigned AllButMain);
    def internalize!(_all_but_main = true)
      raise DeprecationError
    end

    # @LLVMpass sdp
    # /** See llvm::createStripDeadPrototypesPass function. */
    # void LLVMAddStripDeadPrototypesPass(LLVMPassManagerRef PM);
    def sdp!
      raise DeprecationError
    end

    # @LLVMpass strip
    # /** See llvm::createStripSymbolsPass function. */
    # void LLVMAddStripSymbolsPass(LLVMPassManagerRef PM);
    def strip!
      raise DeprecationError
    end
  end
end
