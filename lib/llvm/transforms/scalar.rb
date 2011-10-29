require 'llvm'
require 'llvm/core'

module LLVM
  # @private
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
    # @LLVMpass adce
    def adce!
      C.LLVMAddAggressiveDCEPass(self)
    end
    
    # @LLVMpass simplifycfg
    def simplifycfg!
      C.LLVMAddCFGSimplificationPass(self)
    end
    
    # @LLVMpass dse
    def dse!
      C.LLVMAddDeadStoreEliminationPass(self)
    end
    
    # @LLVMpass gvn
    def gvn!
      C.LLVMAddGVNPass(self)
    end
    
    # @LLVMpass indvars
    def indvars!
      C.LLVMAddIndVarSimplifyPass(self)
    end
    
    # @LLVMpass instcombine
    def instcombine!
      C.LLVMAddInstructionCombiningPass(self)
    end
    
    # @LLVMpass jump-threading
    def jump_threading!
      C.LLVMAddJumpThreadingPass(self)
    end
    
    # @LLVMpass licm
    def licm!
      C.LLVMAddLICMPass(self)
    end
    
    # @LLVMpass loop-deletion
    def loop_deletion!
      C.LLVMAddLoopDeletionPass(self)
    end
    
    # @LLVMpass loop-rotate
    def loop_rotate!
      C.LLVMAddLoopRotatePass(self)
    end
    
    # @LLVMpass loop-unroll
    def loop_unroll!
      C.LLVMAddLoopUnrollPass(self)
    end
    
    # @LLVMpass loop-unswitch
    def loop_unswitch!
      C.LLVMAddLoopUnswitchPass(self)
    end
    
    # @LLVMpass memcpyopt
    def memcpyopt!
      C.LLVMAddMemCpyOptPass(self)
    end
    
    # @LLVMpass mem2reg
    def mem2reg!
      C.LLVMAddPromoteMemoryToRegisterPass(self)
    end
    
    # @LLVMpass reassociate
    def reassociate!
      C.LLVMAddReassociatePass(self)
    end
    
    # @LLVMpass sccp
    def sccp!
      C.LLVMAddSCCPPass(self)
    end
    
    # @LLVMpass scalarrepl
    def scalarrepl!
      C.LLVMAddScalarReplAggregatesPass(self)
    end
    
    # @LLVMpass simplify-libcalls
    def simplify_libcalls!
      C.LLVMAddSimplifyLibCallsPass(self)
    end
    
    # @LLVMpass tailcallelim
    def tailcallelim!
      C.LLVMAddTailCallEliminationPass(self)
    end
    
    # @LLVMpass constprop
    def constprop!
      C.LLVMAddConstantPropagationPass(self)
    end
    
    # @LLVMpass reg2mem
    def reg2mem!
      C.LLVMAddDemoteMemoryToRegisterPass(self)
    end
  end
end
