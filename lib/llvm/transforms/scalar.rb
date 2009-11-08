require 'llvm'
require 'llvm/core'

module LLVM
  module C
    ffi_lib 'LLVMScalarOpts'
    
    attach_function :LLVMAddAggressiveDCEPass, [:pointer], :void
    attach_function :LLVMAddCFGSimplificationPass, [:pointer], :void
    attach_function :LLVMAddCondPropagationPass, [:pointer], :void
    attach_function :LLVMAddDeadStoreEliminationPass, [:pointer], :void
    attach_function :LLVMAddGVNPass, [:pointer], :void
    attach_function :LLVMAddIndVarSimplifyPass, [:pointer], :void
    attach_function :LLVMAddInstructionCombiningPass, [:pointer], :void
    attach_function :LLVMAddJumpThreadingPass, [:pointer], :void
    attach_function :LLVMAddLICMPass, [:pointer], :void
    attach_function :LLVMAddLoopDeletionPass, [:pointer], :void
    attach_function :LLVMAddLoopIndexSplitPass, [:pointer], :void
    attach_function :LLVMAddLoopRotatePass, [:pointer], :void
    attach_function :LLVMAddLoopUnrollPass, [:pointer], :void
    attach_function :LLVMAddLoopUnswitchPass, [:pointer], :void
    attach_function :LLVMAddMemCpyOptPass, [:pointer], :void
    attach_function :LLVMAddPromoteMemoryToRegisterPass, [:pointer], :void
    attach_function :LLVMAddReassociatePass, [:pointer], :void
    attach_function :LLVMAddSCCPPass, [:pointer], :void
    attach_function :LLVMAddScalarReplAggregatesPass, [:pointer], :void
    attach_function :LLVMAddSimplifyLibCallsPass, [:pointer], :void
    attach_function :LLVMAddTailCallEliminationPass, [:pointer], :void
    attach_function :LLVMAddConstantPropagationPass, [:pointer], :void
    attach_function :LLVMAddDemoteMemoryToRegisterPass, [:pointer], :void
  end
  
  class PassManager
    def add(*syms)
      syms.each { |sym| send(:"add_#{sym}_pass") }
    end
    
    def add_aggressive_dce_pass
      C.LLVMAddAggressiveDCEPass(self); nil
    end
    
    def add_cfg_simplification_pass
      C.LLVMAddCFGSimplificationPass(self); nil
    end
    
    def add_cond_propagation_pass
      C.LLVMAddCondPropagationPass(self); nil
    end
    
    def add_dead_store_elimination_pass
      C.LLVMAddDeadStoreEliminationPass(self); nil
    end
    
    def add_gvn_pass
      C.LLVMAddGVNPass(self); nil
    end
    
    def add_ind_var_simplify_pass
      C.LLVMAddIndVarSimplifyPass(self); nil
    end
    
    def add_instruction_combining_pass
      C.LLVMAddInstructionCombiningPass(self); nil
    end
    
    def add_jump_threading_pass
      C.LLVMAddJumpThreadingPass(self); nil
    end
    
    def add_licm_pass
      C.LLVMAddLICMPass(self); nil
    end
    
    def add_loop_deletion_pass
      C.LLVMAddLoopDeletionPass(self); nil
    end
    
    def add_loop_index_split_pass
      C.LLVMAddLoopIndexSplitPass(self); nil
    end
    
    def add_loop_rotate_pass
      C.LLVMAddLoopRotatePass(self); nil
    end
    
    def add_loop_unroll_pass
      C.LLVMAddLoopUnrollPass(self); nil
    end
    
    def add_loop_unswitch_pass
      C.LLVMAddLoopUnswitchPass(self); nil
    end
    
    def add_mem_cpy_opt_pass
      C.LLVMAddMemCpyOptPass(self); nil
    end
    
    def add_promote_memory_to_register_pass
      C.LLVMAddPromoteMemoryToRegisterPass(self); nil
    end
    
    def add_reassociate_pass
      C.LLVMAddReassociatePass(self); nil
    end
    
    def add_sccp_pass
      C.LLVMAddSCCPPass(self); nil
    end
    
    def add_scalar_repl_aggregates_pass
      C.LLVMAddScalarReplAggregatesPass(self); nil
    end
    
    def add_simplify_lib_calls_pass
      C.LLVMAddSimplifyLibCallsPass(self); nil
    end
    
    def add_tail_call_elimination_pass
      C.LLVMAddTailCallEliminationPass(self); nil
    end
    
    def add_constant_propagation_pass
      C.LLVMAddConstantPropagationPass(self); nil
    end
    
    def add_demote_memory_to_register_pass
      C.LLVMAddDemoteMemoryToRegisterPass(self); nil
    end
  end
end
