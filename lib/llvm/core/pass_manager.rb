module LLVM
  # The PassManager runs a queue of passes on a module. See
  # http://llvm.org/docs/Passes.html for the list of available passes.
  class PassManager
    # Creates a new pass manager on the given ExecutionEngine.
    def initialize(execution_engine)
      ptr = C.LLVMCreatePassManager()
      C.LLVMAddTargetData(
        C.LLVMGetExecutionEngineTargetData(execution_engine), ptr)
      @ptr = ptr
    end
    
    # @private
    def to_ptr
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

    # Runs the passes on the given module.
    def run(mod)
      C.LLVMRunPassManager(self, mod)
    end
    
    # Disposes the pass manager.
    def dispose
      C.LLVMDisposePassManager(self)
    end
  end

  class FunctionPassManager < PassManager
    # Creates a new pass manager on the given ExecutionEngine and Module.
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

    # Runs the passes on the given function.
    def run(fn)
      C.LLVMRunFunctionPassManager(self, fn)
    end
  end
end
