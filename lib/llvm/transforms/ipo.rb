# frozen_string_literal: true

# Interprocedural optimization (IPO)
require 'llvm'
require 'llvm/core'
require 'llvm/transforms/ipo_ffi'

module LLVM
  class PassManager
    # @LLVMpass arg_promotion
    def arg_promote!
      warn('arg_promote! / LLVMAddArgumentPromotionPass was removed from LLVM')
    end

    # @LLVMpass const_merge
    # /** See llvm::createConstantMergePass function. */
    # void LLVMAddConstantMergePass(LLVMPassManagerRef PM);
    def const_merge!
      C.add_constant_merge_pass(self)
    end

    # @LLVMpass mergefunc
    # /** See llvm::createMergeFunctionsPass function. */
    # void LLVMAddMergeFunctionsPass(LLVMPassManagerRef PM);
    def mergefunc!
      C.add_merge_functions_pass(self)
    end

    # @LLVMpass called-value-propagation
    # /** See llvm::createCalledValuePropagationPass function. */
    # void LLVMAddCalledValuePropagationPass(LLVMPassManagerRef PM);
    def called_value_propagation!
      C.add_called_value_propagation_pass(self)
    end

    # @LLVMpass dae
    # /** See llvm::createDeadArgEliminationPass function. */
    # void LLVMAddDeadArgEliminationPass(LLVMPassManagerRef PM);
    def dae!
      C.add_dead_arg_elimination_pass(self)
    end

    # @LLVMpass function_attrs
    # /** See llvm::createFunctionAttrsPass function. */
    # void LLVMAddFunctionAttrsPass(LLVMPassManagerRef PM);
    def fun_attrs!
      C.add_function_attrs_pass(self)
    end

    # @LLVMpass inline
    # /** See llvm::createFunctionInliningPass function. */
    # void LLVMAddFunctionInliningPass(LLVMPassManagerRef PM);
    def inline!
      C.add_function_inlining_pass(self)
    end

    # @LLVMpass always_inline
    # /** See llvm::createAlwaysInlinerPass function. */
    # void LLVMAddAlwaysInlinerPass(LLVMPassManagerRef PM);
    def always_inline!
      C.add_always_inliner_pass(self)
    end

    # @LLVMpass gdce
    # /** See llvm::createGlobalDCEPass function. */
    # void LLVMAddGlobalDCEPass(LLVMPassManagerRef PM);
    def gdce!
      C.add_global_dce_pass(self)
    end

    # @LLVMpass global_opt
    # /** See llvm::createGlobalOptimizerPass function. */
    # void LLVMAddGlobalOptimizerPass(LLVMPassManagerRef PM);
    def global_opt!
      C.add_global_optimizer_pass(self)
    end

    # @LLVMpass ipcp
    def ipcp!
      warn('ipcp! / LLVMAddIPConstantPropagationPass was removed from LLVM')
    end

    # @LLVMpass prune_eh
    # /** See llvm::createPruneEHPass function. */
    # void LLVMAddPruneEHPass(LLVMPassManagerRef PM);
    def prune_eh!
      warn('prune_eh! / LLVMAddPruneEHPass was removed in LLVM 16')
    end

    # @LLVMpass ipsccp
    # /** See llvm::createIPSCCPPass function. */
    # void LLVMAddIPSCCPPass(LLVMPassManagerRef PM);
    def ipsccp!
      C.add_ipsccp_pass(self)
    end

    # @LLVMpass internalize
    # /** See llvm::createInternalizePass function. */
    # void LLVMAddInternalizePass(LLVMPassManagerRef, unsigned AllButMain);
    def internalize!(all_but_main = true)
      C.add_internalize_pass(self, all_but_main ? 1 : 0)
    end

    # @LLVMpass sdp
    # /** See llvm::createStripDeadPrototypesPass function. */
    # void LLVMAddStripDeadPrototypesPass(LLVMPassManagerRef PM);
    def sdp!
      C.add_strip_dead_prototypes_pass(self)
    end

    # @LLVMpass strip
    # /** See llvm::createStripSymbolsPass function. */
    # void LLVMAddStripSymbolsPass(LLVMPassManagerRef PM);
    def strip!
      C.add_strip_symbols_pass(self)
    end

  end

  module C
    attach_function :add_merge_functions_pass, :LLVMAddMergeFunctionsPass, [:pointer], :void
    attach_function :add_called_value_propagation_pass, :LLVMAddCalledValuePropagationPass, [:pointer], :void
  end
end
