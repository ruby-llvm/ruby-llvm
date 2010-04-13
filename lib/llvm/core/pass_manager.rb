module LLVM
  # The PassManager runs a queue of passes on a module. See
  # http://llvm.org/docs/Passes.html for the list of available passes.
  # Currently, only scalar transformation passes are supported.
  class PassManager
    def initialize(execution_engine)
      ptr = C.LLVMCreatePassManager()
      C.LLVMAddTargetData(
        C.LLVMGetExecutionEngineTargetData(execution_engine), ptr)
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def <<(name)
      send(:"#{name}!")
      self
    end
    
    def run(mod)
      C.LLVMRunPassManager(self, mod)
    end
    
    def dispose
      C.LLVMDisposePassManager(self)
    end
  end
end
