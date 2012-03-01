require 'llvm'
require 'llvm/core'

module LLVM
  # @private
  module C
    attach_function :add_aggressive_dce_pass, :LLVMAddAggressiveDCEPass, [:pointer], :void
    attach_function :add_cfg_simplification_pass, :LLVMAddCFGSimplificationPass, [:pointer], :void
    attach_function :add_dead_store_elimination_pass, :LLVMAddDeadStoreEliminationPass, [:pointer], :void
    attach_function :add_gvn_pass, :LLVMAddGVNPass, [:pointer], :void
    attach_function :add_ind_var_simplify_pass, :LLVMAddIndVarSimplifyPass, [:pointer], :void
    attach_function :add_instruction_combining_pass, :LLVMAddInstructionCombiningPass, [:pointer], :void
    attach_function :add_jump_threading_pass, :LLVMAddJumpThreadingPass, [:pointer], :void
    attach_function :add_licm_pass, :LLVMAddLICMPass, [:pointer], :void
    attach_function :add_loop_deletion_pass, :LLVMAddLoopDeletionPass, [:pointer], :void
    attach_function :add_loop_rotate_pass, :LLVMAddLoopRotatePass, [:pointer], :void
    attach_function :add_loop_unroll_pass, :LLVMAddLoopUnrollPass, [:pointer], :void
    attach_function :add_loop_unswitch_pass, :LLVMAddLoopUnswitchPass, [:pointer], :void
    attach_function :add_mem_cpy_opt_pass, :LLVMAddMemCpyOptPass, [:pointer], :void
    attach_function :add_promote_memory_to_register_pass, :LLVMAddPromoteMemoryToRegisterPass, [:pointer], :void
    attach_function :add_reassociate_pass, :LLVMAddReassociatePass, [:pointer], :void
    attach_function :add_sccp_pass, :LLVMAddSCCPPass, [:pointer], :void
    attach_function :add_scalar_repl_aggregates_pass, :LLVMAddScalarReplAggregatesPass, [:pointer], :void
    attach_function :add_simplify_lib_calls_pass, :LLVMAddSimplifyLibCallsPass, [:pointer], :void
    attach_function :add_tail_call_elimination_pass, :LLVMAddTailCallEliminationPass, [:pointer], :void
    attach_function :add_constant_propagation_pass, :LLVMAddConstantPropagationPass, [:pointer], :void
    attach_function :add_demote_memory_to_register_pass, :LLVMAddDemoteMemoryToRegisterPass, [:pointer], :void
  end
  
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
  end
end
