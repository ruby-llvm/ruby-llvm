require 'llvm'
require 'llvm/core'

module LLVM
  module C
    attach_function :LLVMAddAggressiveDCEPass, [:pointer], :void
    attach_function :LLVMAddCFGSimplificationPass, [:pointer], :void
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
    def adce!
      C.LLVMAddAggressiveDCEPass(self)
    end
    
    def simplifycfg!
      C.LLVMAddCFGSimplificationPass(self)
    end
    
    def dse!
      C.LLVMAddDeadStoreEliminationPass(self)
    end
    
    def gvn!
      C.LLVMAddGVNPass(self)
    end
    
    def indvars!
      C.LLVMAddIndVarSimplifyPass(self)
    end
    
    def instcombine!
      C.LLVMAddInstructionCombiningPass(self)
    end
    
    def jump_threading!
      C.LLVMAddJumpThreadingPass(self)
    end
    
    def licm!
      C.LLVMAddLICMPass(self)
    end
    
    def loop_deletion!
      C.LLVMAddLoopDeletionPass(self)
    end
    
    def loop_index_split!
      C.LLVMAddLoopIndexSplitPass(self)
    end
    
    def loop_rotate!
      C.LLVMAddLoopRotatePass(self)
    end
    
    def loop_unroll!
      C.LLVMAddLoopUnrollPass(self)
    end
    
    def loop_unswitch!
      C.LLVMAddLoopUnswitchPass(self)
    end
    
    def memcpyopt!
      C.LLVMAddMemCpyOptPass(self)
    end
    
    def mem2reg!
      C.LLVMAddPromoteMemoryToRegisterPass(self)
    end
    
    def reassociate!
      C.LLVMAddReassociatePass(self)
    end
    
    def sccp!
      C.LLVMAddSCCPPass(self)
    end
    
    def scalarrepl!
      C.LLVMAddScalarReplAggregatesPass(self)
    end
    
    def simplify_libcalls!
      C.LLVMAddSimplifyLibCallsPass(self)
    end
    
    def tailcallelim!
      C.LLVMAddTailCallEliminationPass(self)
    end
    
    def constprop!
      C.LLVMAddConstantPropagationPass(self)
    end
    
    def reg2mem!
      C.LLVMAddDemoteMemoryToRegisterPass(self)
    end
  end
end
