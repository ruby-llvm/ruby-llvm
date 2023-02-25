# frozen_string_literal: true

require 'llvm'
require 'llvm/core'
require 'llvm/transforms/scalar_ffi'

module LLVM
  class PassManager
    # @LLVMpass adce
    # /** See llvm::createAggressiveDCEPass function. */
    # void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM);
    def adce!
      C.add_aggressive_dce_pass(self)
    end

    # @LLVMpass dce
    # /** See llvm::createDeadCodeEliminationPass function. */
    # void LLVMAddDCEPass(LLVMPassManagerRef PM);
    def dce!
      C.add_dce_pass(self)
    end

    # @LLVMpass bdce
    # /** See llvm::createBitTrackingDCEPass function. */
    # void LLVMAddBitTrackingDCEPass(LLVMPassManagerRef PM);
    def bdce!
      C.add_bit_tracking_dce_pass(self)
    end

    # @LLVMpass alignment_from_assumptions
    # /** See llvm::createAlignmentFromAssumptionsPass function. */
    # void LLVMAddAlignmentFromAssumptionsPass(LLVMPassManagerRef PM);
    def alignment_from_assumptions!
      C.add_alignment_from_assumptions_pass(self)
    end

    # @LLVMpass simplifycfg
    # /** See llvm::createCFGSimplificationPass function. */
    # void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM);
    def simplifycfg!
      C.add_cfg_simplification_pass(self)
    end

    # @LLVMpass dse
    # /** See llvm::createDeadStoreEliminationPass function. */
    # void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM);
    def dse!
      C.add_dead_store_elimination_pass(self)
    end

    # @LLVMPass scalarizer
    # /** See llvm::createScalarizerPass function. */
    # void LLVMAddScalarizerPass(LLVMPassManagerRef PM);
    def scalarizer!
      C.add_scalarizer_pass(self)
    end

    # @LLVMpass mldst-motion
    # /** See llvm::createMergedLoadStoreMotionPass function. */
    # void LLVMAddMergedLoadStoreMotionPass(LLVMPassManagerRef PM);
    def mldst_motion!
      C.add_merged_load_store_motion_pass(self)
    end

    # @LLVMpass gvn
    # /** See llvm::createGVNPass function. */
    # void LLVMAddGVNPass(LLVMPassManagerRef PM);
    def gvn!
      C.add_gvn_pass(self)
    end

    # @LLVMpass newgvn
    # /** See llvm::createGVNPass function. */
    # void LLVMAddNewGVNPass(LLVMPassManagerRef PM);
    def newgvn!
      C.add_new_gvn_pass(self)
    end

    # @LLVMpass indvars
    # /** See llvm::createIndVarSimplifyPass function. */
    # void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM);
    def indvars!
      C.add_ind_var_simplify_pass(self)
    end

    # @LLVMpass instcombine
    # /** See llvm::createInstructionCombiningPass function. */
    # void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);
    def instcombine!
      C.add_instruction_combining_pass(self)
    end

    # @LLVMpass instsimplify
    # /** See llvm::createInstSimplifyLegacyPass function. */
    # void LLVMAddInstructionSimplifyPass(LLVMPassManagerRef PM);
    def instsimplify!
      C.add_instruction_simplify_pass(self)
    end

    # @LLVMpass jump-threading
    # /** See llvm::createJumpThreadingPass function. */
    # void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM);
    def jump_threading!
      C.add_jump_threading_pass(self)
    end

    # @LLVMpass licm
    # /** See llvm::createLICMPass function. */
    # void LLVMAddLICMPass(LLVMPassManagerRef PM);
    def licm!
      C.add_licm_pass(self)
    end

    # @LLVMpass loop-deletion
    # /** See llvm::createLoopDeletionPass function. */
    # void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM);
    def loop_deletion!
      C.add_loop_deletion_pass(self)
    end

    # @LLVMpass loop-idiom
    # /** See llvm::createLoopIdiomPass function */
    # void LLVMAddLoopIdiomPass(LLVMPassManagerRef PM);
    def loop_idiom!
      C.add_loop_idiom_pass(self)
    end

    # @LLVMpass loop-rotate
    # /** See llvm::createLoopRotatePass function. */
    # void LLVMAddLoopRotatePass(LLVMPassManagerRef PM);
    def loop_rotate!
      C.add_loop_rotate_pass(self)
    end

    # @LLVMpass loop-reroll
    # /** See llvm::createLoopRerollPass function. */
    # void LLVMAddLoopRerollPass(LLVMPassManagerRef PM);
    def loop_reroll!
      C.add_loop_reroll_pass(self)
    end

    # @LLVMpass loop-unroll
    #     /** See llvm::createLoopUnrollPass function. */
    #     void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM);
    def loop_unroll!
      C.add_loop_unroll_pass(self)
    end

    # @LLVMpass loop-unroll-and-jam
    # /** See llvm::createLoopUnrollAndJamPass function. */
    # void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);
    def loop_unroll_and_jam!
      C.add_loop_unroll_and_jam_pass(self)
    end

    # @LLVMpass loop-unswitch
    def loop_unswitch!
      warn('loop_unswitch! / LLVMAddLoopUnswitchPass was removed in LLVM 15')
    end

    # @LLVMpass loweratomic
    # /** See llvm::createLowerAtomicPass function. */
    # void LLVMAddLowerAtomicPass(LLVMPassManagerRef PM);
    def loweratomic!
      C.add_lower_atomic_pass(self)
    end

    # @LLVMpass memcpyopt
    # /** See llvm::createMemCpyOptPass function. */
    # void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM);
    def memcpyopt!
      C.add_mem_cpy_opt_pass(self)
    end

    # @LLVMpass partially-inline-libcalls
    # /** See llvm::createPartiallyInlineLibCallsPass function. */
    # void LLVMAddPartiallyInlineLibCallsPass(LLVMPassManagerRef PM);
    def partially_inline_libcalls!
      C.add_partially_inline_lib_calls_pass(self)
    end

    # @LLVMpass reassociate
    # /** See llvm::createReassociatePass function. */
    # void LLVMAddReassociatePass(LLVMPassManagerRef PM);
    def reassociate!
      C.add_reassociate_pass(self)
    end

    # @LLVMpass sccp
    # /** See llvm::createSCCPPass function. */
    # void LLVMAddSCCPPass(LLVMPassManagerRef PM);
    def sccp!
      C.add_sccp_pass(self)
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM);
    def scalarrepl!
      C.add_scalar_repl_aggregates_pass(self)
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPassSSA(LLVMPassManagerRef PM);
    def scalarrepl_ssa!
      C.add_scalar_repl_aggregates_pass_ssa(self)
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM,
    #                                                   int Threshold);
    # threshold appears unused: https://llvm.org/doxygen/Scalar_8cpp_source.html#l00211
    def scalarrepl_threshold!(threshold = 0)
      C.add_scalar_repl_aggregates_pass_with_threshold(self, threshold)
    end

    # @LLVMpass simplify-libcalls
    # /** See llvm::createSimplifyLibCallsPass function. */
    # void LLVMAddSimplifyLibCallsPass(LLVMPassManagerRef PM);
    # removed: https://llvm.org/doxygen/Scalar_8cpp_source.html#l00211
    def simplify_libcalls!
      warn('simplify_libcalls! / LLVMAddSimplifyLibCallsPass was removed from LLVM')
    end

    # @LLVMpass tailcallelim
    # /** See llvm::createTailCallEliminationPass function. */
    # void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM);
    def tailcallelim!
      C.add_tail_call_elimination_pass(self)
    end

    # @LLVMpass constprop
    def constprop!
      warn('constprop! / LLVMAddConstantPropagationPass was removed from LLVM')
    end

    # @LLVMpass reg2mem
    # /** See llvm::demotePromoteMemoryToRegisterPass function. */
    # void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM);
    def reg2mem!
      C.add_demote_memory_to_register_pass(self)
    end

    # @LLVMpass verify
    # /** See llvm::createVerifierPass function. */
    # void LLVMAddVerifierPass(LLVMPassManagerRef PM);
    def verify!
      C.add_verifier_pass(self)
    end

    # @LLVMpass cvprop
    # /** See llvm::createCorrelatedValuePropagationPass function */
    # void LLVMAddCorrelatedValuePropagationPass(LLVMPassManagerRef PM);
    def cvprop!
      C.add_correlated_value_propagation_pass(self)
    end

    # @LLVMpass early-cse
    # /** See llvm::createEarlyCSEPass function */
    # void LLVMAddEarlyCSEPass(LLVMPassManagerRef PM);
    def early_cse!
      C.add_early_cse_pass(self)
    end

    # @LLVMpass early-cse-memssa
    # /** See llvm::createEarlyCSEPass function */
    # void LLVMAddEarlyCSEMemSSAPass(LLVMPassManagerRef PM);
    def early_cse_memssa!
      C.add_early_cse_mem_ssa_pass(self)
    end

    # @LLVMpass lower-expect
    # /** See llvm::createLowerExpectIntrinsicPass function */
    # void LLVMAddLowerExpectIntrinsicPass(LLVMPassManagerRef PM);
    def lower_expect!
      C.add_lower_expect_intrinsic_pass(self)
    end

    # @LLVMPass lower-constant-intrinsics
    # /** See llvm::createLowerConstantIntrinsicsPass function */
    # void LLVMAddLowerConstantIntrinsicsPass(LLVMPassManagerRef PM);
    def lower_constant_intrinsics!
      C.add_lower_constant_intrinsics_pass(self)
    end

    # @LLVMpass tbaa
    # /** See llvm::createTypeBasedAliasAnalysisPass function */
    # void LLVMAddTypeBasedAliasAnalysisPass(LLVMPassManagerRef PM);
    def tbaa!
      C.add_type_based_alias_analysis_pass(self)
    end

    # @ LLVMPass scoped-noalias-aa
    # /** See llvm::createScopedNoAliasAAPass function */
    # void LLVMAddScopedNoAliasAAPass(LLVMPassManagerRef PM);
    def scoped_noalias_aa!
      C.add_scoped_no_alias_aa_pass(self)
    end

    # @LLVMpass basicaa
    # /** See llvm::createBasicAliasAnalysisPass function */
    # void LLVMAddBasicAliasAnalysisPass(LLVMPassManagerRef PM);
    def basicaa!
      C.add_basic_alias_analysis_pass(self)
    end

    # @LLVMpass mergereturn
    # /** See llvm::createUnifyFunctionExitNodesPass function */
    # void LLVMAddUnifyFunctionExitNodesPass(LLVMPassManagerRef PM);
    def mergereturn!
      C.add_unify_function_exit_nodes_pass(self)
    end

  end

  module C
    attach_function :add_dce_pass, :LLVMAddDCEPass, [:pointer], :void
    attach_function :add_instruction_simplify_pass, :LLVMAddInstructionSimplifyPass, [:pointer], :void
    attach_function :add_loop_unroll_and_jam_pass, :LLVMAddLoopUnrollAndJamPass, [:pointer], :void
    attach_function :add_lower_atomic_pass, :LLVMAddLowerAtomicPass, [:pointer], :void
    attach_function :add_lower_constant_intrinsics_pass, :LLVMAddLowerConstantIntrinsicsPass, [:pointer], :void
    attach_function :add_unify_function_exit_nodes_pass, :LLVMAddUnifyFunctionExitNodesPass, [:pointer], :void
  end
end
