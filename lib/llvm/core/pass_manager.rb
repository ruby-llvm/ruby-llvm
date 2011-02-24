module LLVM
  # The PassManager runs a queue of passes on a module. See
  # http://llvm.org/docs/Passes.html for the list of available passes.
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

    def do_initialization
    end

    def do_finalization
    end

    def run(mod)
      C.LLVMRunPassManager(self, mod)
    end
    
    def dispose
      C.LLVMDisposePassManager(self)
    end
  end

  class FunctionPassManager < PassManager
    def initialize(execution_engine, mod)
      ptr = C.LLVMCreateFunctionPassManagerForModule(mod)
      C.LLVMAddTargetData(
        C.LLVMGetExecutionEngineTargetData(execution_engine), ptr)
      @ptr = ptr
    end

    def do_initialization
      C.LLVMInitializeFunctionPassManager(self) != 0
    end

    def do_finalization
      C.LLVMFinalizeFunctionPassManager(self) != 0
    end

    def run(fn)
      C.LLVMRunFunctionPassManager(self, fn)
    end
  end
end
