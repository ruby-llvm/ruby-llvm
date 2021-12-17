require 'llvm'
require 'llvm/core'
require 'llvm/transforms/scalar_ffi'

module LLVM
  class PassManager
    # @LLVMpass adce
    def adce!
      C.add_aggressive_dce_pass(self)
    end

    # @LLVMpass simplifycfg
    def simplifycfg!
      C.add_cfg_simplification_pass(self)
    end

    # @LLVMpass dse
    def dse!
      C.add_dead_store_elimination_pass(self)
    end

    # @LLVMpass gvn
    def gvn!
      C.add_gvn_pass(self)
    end

    # @LLVMpass indvars
    def indvars!
      C.add_ind_var_simplify_pass(self)
    end

    # @LLVMpass instcombine
    def instcombine!
      C.add_instruction_combining_pass(self)
    end

    # @LLVMpass jump-threading
    def jump_threading!
      C.add_jump_threading_pass(self)
    end

    # @LLVMpass licm
    def licm!
      C.add_licm_pass(self)
    end

    # @LLVMpass loop-deletion
    def loop_deletion!
      C.add_loop_deletion_pass(self)
    end

    # @LLVMpass loop-idiom
    def loop_idiom!
      C.add_loop_idiom_pass(self)
    end

    # @LLVMpass loop-rotate
    def loop_rotate!
      C.add_loop_rotate_pass(self)
    end

    # @LLVMpass loop-unroll
    def loop_unroll!
      C.add_loop_unroll_pass(self)
    end

    # @LLVMpass loop-unswitch
    def loop_unswitch!
      C.add_loop_unswitch_pass(self)
    end

    # @LLVMpass memcpyopt
    def memcpyopt!
      C.add_mem_cpy_opt_pass(self)
    end

    # @LLVMpass mem2reg
    def mem2reg!
      C.add_promote_memory_to_register_pass(self)
    end

    # @LLVMpass reassociate
    def reassociate!
      C.add_reassociate_pass(self)
    end

    # @LLVMpass sccp
    def sccp!
      C.add_sccp_pass(self)
    end

    # @LLVMpass scalarrepl
    def scalarrepl!
      C.add_scalar_repl_aggregates_pass(self)
    end

    # @LLVMpass scalarrepl
    def scalarrepl_ssa!
      C.add_scalar_repl_aggregates_pass_ssa(self)
    end

    # @LLVMpass scalarrepl
    def scalarrepl_threshold!(threshold)
      C.add_scalar_repl_aggregates_pass(self, threshold)
    end

    # @LLVMpass simplify-libcalls
    def simplify_libcalls!
      C.add_simplify_lib_calls_pass(self)
    end

    # @LLVMpass tailcallelim
    def tailcallelim!
      C.add_tail_call_elimination_pass(self)
    end

    # @LLVMpass constprop
    def constprop!
      C.add_constant_propagation_pass(self)
    end

    # @LLVMpass reg2mem
    def reg2mem!
      C.add_demote_memory_to_register_pass(self)
    end

    # @LLVMpass cvprop
    def cvprop!
      C.add_correlated_value_propagation_pass(self)
    end

    # @LLVMpass early-cse
    def early_cse!
      C.add_early_cse_pass(self)
    end

    # @LLVMpass lower-expect
    def lower_expect!
      C.add_lower_expect_intrinsic_pass(self)
    end

    # @LLVMpass tbaa
    def tbaa!
      C.add_type_based_alias_analysis_pass(self)
    end

    # @LLVMpass basicaa
    def basicaa!
      C.add_basic_alias_analysis_pass(self)
    end

    # @LLVMpass mergefunc
    def mergefunc!
      C.add_merge_functions_pass(self)
    end

  end

  module C
    attach_function :add_merge_functions_pass, :LLVMAddMergeFunctionsPass, [:pointer], :void
  end
end
