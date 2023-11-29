# frozen_string_literal: true

require 'llvm'
require 'llvm/core'

module LLVM
  class PassManager
    # @LLVMpass adce
    # /** See llvm::createAggressiveDCEPass function. */
    # void LLVMAddAggressiveDCEPass(LLVMPassManagerRef PM);
    def adce!
      raise DeprecationError
    end

    # @LLVMpass dce
    # /** See llvm::createDeadCodeEliminationPass function. */
    # void LLVMAddDCEPass(LLVMPassManagerRef PM);
    def dce!
      raise DeprecationError
    end

    # @LLVMpass bdce
    # /** See llvm::createBitTrackingDCEPass function. */
    # void LLVMAddBitTrackingDCEPass(LLVMPassManagerRef PM);
    def bdce!
      raise DeprecationError
    end

    # @LLVMpass alignment_from_assumptions
    # /** See llvm::createAlignmentFromAssumptionsPass function. */
    # void LLVMAddAlignmentFromAssumptionsPass(LLVMPassManagerRef PM);
    def alignment_from_assumptions!
      raise DeprecationError
    end

    # @LLVMpass simplifycfg
    # /** See llvm::createCFGSimplificationPass function. */
    # void LLVMAddCFGSimplificationPass(LLVMPassManagerRef PM);
    def simplifycfg!
      raise DeprecationError
    end

    # @LLVMpass dse
    # /** See llvm::createDeadStoreEliminationPass function. */
    # void LLVMAddDeadStoreEliminationPass(LLVMPassManagerRef PM);
    def dse!
      raise DeprecationError
    end

    # @LLVMPass scalarizer
    # /** See llvm::createScalarizerPass function. */
    # void LLVMAddScalarizerPass(LLVMPassManagerRef PM);
    def scalarizer!
      raise DeprecationError
    end

    # @LLVMpass mldst-motion
    # /** See llvm::createMergedLoadStoreMotionPass function. */
    # void LLVMAddMergedLoadStoreMotionPass(LLVMPassManagerRef PM);
    def mldst_motion!
      raise DeprecationError
    end

    # @LLVMpass gvn
    # /** See llvm::createGVNPass function. */
    # void LLVMAddGVNPass(LLVMPassManagerRef PM);
    def gvn!
      raise DeprecationError
    end

    # @LLVMpass newgvn
    # /** See llvm::createGVNPass function. */
    # void LLVMAddNewGVNPass(LLVMPassManagerRef PM);
    def newgvn!
      raise DeprecationError
    end

    # @LLVMpass indvars
    # /** See llvm::createIndVarSimplifyPass function. */
    # void LLVMAddIndVarSimplifyPass(LLVMPassManagerRef PM);
    def indvars!
      raise DeprecationError
    end

    # @LLVMpass instcombine
    # /** See llvm::createInstructionCombiningPass function. */
    # void LLVMAddInstructionCombiningPass(LLVMPassManagerRef PM);
    def instcombine!
      raise DeprecationError
    end

    # @LLVMpass instsimplify
    # /** See llvm::createInstSimplifyLegacyPass function. */
    # void LLVMAddInstructionSimplifyPass(LLVMPassManagerRef PM);
    def instsimplify!
      raise DeprecationError
    end

    # @LLVMpass jump-threading
    # /** See llvm::createJumpThreadingPass function. */
    # void LLVMAddJumpThreadingPass(LLVMPassManagerRef PM);
    def jump_threading!
      raise DeprecationError
    end

    # @LLVMpass licm
    # /** See llvm::createLICMPass function. */
    # void LLVMAddLICMPass(LLVMPassManagerRef PM);
    def licm!
      raise DeprecationError
    end

    # @LLVMpass loop-deletion
    # /** See llvm::createLoopDeletionPass function. */
    # void LLVMAddLoopDeletionPass(LLVMPassManagerRef PM);
    def loop_deletion!
      raise DeprecationError
    end

    # @LLVMpass loop-idiom
    # /** See llvm::createLoopIdiomPass function */
    # void LLVMAddLoopIdiomPass(LLVMPassManagerRef PM);
    def loop_idiom!
      raise DeprecationError
    end

    # @LLVMpass loop-rotate
    # /** See llvm::createLoopRotatePass function. */
    # void LLVMAddLoopRotatePass(LLVMPassManagerRef PM);
    def loop_rotate!
      raise DeprecationError
    end

    # @LLVMpass loop-reroll
    # /** See llvm::createLoopRerollPass function. */
    # void LLVMAddLoopRerollPass(LLVMPassManagerRef PM);
    def loop_reroll!
      raise DeprecationError
    end

    # @LLVMpass loop-unroll
    #     /** See llvm::createLoopUnrollPass function. */
    #     void LLVMAddLoopUnrollPass(LLVMPassManagerRef PM);
    def loop_unroll!
      raise DeprecationError
    end

    # @LLVMpass loop-unroll-and-jam
    # /** See llvm::createLoopUnrollAndJamPass function. */
    # void LLVMAddLoopUnrollAndJamPass(LLVMPassManagerRef PM);
    def loop_unroll_and_jam!
      raise DeprecationError
    end

    # @LLVMpass loop-unswitch
    def loop_unswitch!
      raise DeprecationError
    end

    # @LLVMpass loweratomic
    # /** See llvm::createLowerAtomicPass function. */
    # void LLVMAddLowerAtomicPass(LLVMPassManagerRef PM);
    def loweratomic!
      raise DeprecationError
    end

    # @LLVMpass memcpyopt
    # /** See llvm::createMemCpyOptPass function. */
    # void LLVMAddMemCpyOptPass(LLVMPassManagerRef PM);
    def memcpyopt!
      raise DeprecationError
    end

    # @LLVMpass partially-inline-libcalls
    # /** See llvm::createPartiallyInlineLibCallsPass function. */
    # void LLVMAddPartiallyInlineLibCallsPass(LLVMPassManagerRef PM);
    def partially_inline_libcalls!
      raise DeprecationError
    end

    # @LLVMpass reassociate
    # /** See llvm::createReassociatePass function. */
    # void LLVMAddReassociatePass(LLVMPassManagerRef PM);
    def reassociate!
      raise DeprecationError
    end

    # @LLVMpass sccp
    # /** See llvm::createSCCPPass function. */
    # void LLVMAddSCCPPass(LLVMPassManagerRef PM);
    def sccp!
      raise DeprecationError
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPass(LLVMPassManagerRef PM);
    def scalarrepl!
      raise DeprecationError
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPassSSA(LLVMPassManagerRef PM);
    def scalarrepl_ssa!
      raise DeprecationError
    end

    # @LLVMpass sroa
    # /** See llvm::createSROAPass function. */
    # void LLVMAddScalarReplAggregatesPassWithThreshold(LLVMPassManagerRef PM,
    #                                                   int Threshold);
    # threshold appears unused: https://llvm.org/doxygen/Scalar_8cpp_source.html#l00211
    def scalarrepl_threshold!(_threshold = 0)
      raise DeprecationError
    end

    # @LLVMpass simplify-libcalls
    # /** See llvm::createSimplifyLibCallsPass function. */
    # void LLVMAddSimplifyLibCallsPass(LLVMPassManagerRef PM);
    # removed: https://llvm.org/doxygen/Scalar_8cpp_source.html#l00211
    def simplify_libcalls!
      raise DeprecationError
    end

    # @LLVMpass tailcallelim
    # /** See llvm::createTailCallEliminationPass function. */
    # void LLVMAddTailCallEliminationPass(LLVMPassManagerRef PM);
    def tailcallelim!
      raise DeprecationError
    end

    # @LLVMpass constprop
    def constprop!
      raise DeprecationError
    end

    # @LLVMpass reg2mem
    # /** See llvm::demotePromoteMemoryToRegisterPass function. */
    # void LLVMAddDemoteMemoryToRegisterPass(LLVMPassManagerRef PM);
    def reg2mem!
      raise DeprecationError
    end

    # @LLVMpass verify
    # /** See llvm::createVerifierPass function. */
    # void LLVMAddVerifierPass(LLVMPassManagerRef PM);
    def verify!
      raise DeprecationError
    end

    # @LLVMpass cvprop
    # /** See llvm::createCorrelatedValuePropagationPass function */
    # void LLVMAddCorrelatedValuePropagationPass(LLVMPassManagerRef PM);
    def cvprop!
      raise DeprecationError
    end

    # @LLVMpass early-cse
    # /** See llvm::createEarlyCSEPass function */
    # void LLVMAddEarlyCSEPass(LLVMPassManagerRef PM);
    def early_cse!
      raise DeprecationError
    end

    # @LLVMpass early-cse-memssa
    # /** See llvm::createEarlyCSEPass function */
    # void LLVMAddEarlyCSEMemSSAPass(LLVMPassManagerRef PM);
    def early_cse_memssa!
      raise DeprecationError
    end

    # @LLVMpass lower-expect
    # /** See llvm::createLowerExpectIntrinsicPass function */
    # void LLVMAddLowerExpectIntrinsicPass(LLVMPassManagerRef PM);
    def lower_expect!
      raise DeprecationError
    end

    # @LLVMPass lower-constant-intrinsics
    # /** See llvm::createLowerConstantIntrinsicsPass function */
    # void LLVMAddLowerConstantIntrinsicsPass(LLVMPassManagerRef PM);
    def lower_constant_intrinsics!
      raise DeprecationError
    end

    # @LLVMpass tbaa
    # /** See llvm::createTypeBasedAliasAnalysisPass function */
    # void LLVMAddTypeBasedAliasAnalysisPass(LLVMPassManagerRef PM);
    def tbaa!
      raise DeprecationError
    end

    # @ LLVMPass scoped-noalias-aa
    # /** See llvm::createScopedNoAliasAAPass function */
    # void LLVMAddScopedNoAliasAAPass(LLVMPassManagerRef PM);
    def scoped_noalias_aa!
      raise DeprecationError
    end

    # @LLVMpass basicaa
    # /** See llvm::createBasicAliasAnalysisPass function */
    # void LLVMAddBasicAliasAnalysisPass(LLVMPassManagerRef PM);
    def basicaa!
      raise DeprecationError
    end

    # @LLVMpass mergereturn
    # /** See llvm::createUnifyFunctionExitNodesPass function */
    # void LLVMAddUnifyFunctionExitNodesPass(LLVMPassManagerRef PM);
    def mergereturn!
      raise DeprecationError
    end

  end
end
