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

      do_initialization
    end
    
    # @private
    def to_ptr
      @ptr
    end
    
    # Append a pass to the pass queue.
    # @param [Symbol]
    # @return [LLVM::PassManager]
    def <<(name)
      send(:"#{name}!")
      self
    end

    # Run the pass queue on the given module.
    # @param [LLVM::Module]
    # @return [true, false] Indicates whether the module was modified.
    def run(mod)
      C.LLVMRunPassManager(self, mod) != 0
    end
    
    # Disposes the pass manager.
    def dispose
      do_finalization
      C.LLVMDisposePassManager(self)
    end

    protected

    def do_initialization
    end

    def do_finalization
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

    # Run the pass queue on the given function.
    # @param [LLVM::Function]
    # @return [true, false] indicates whether the function was modified.
    def run(fn)
      C.LLVMRunFunctionPassManager(self, fn) != 0
    end

    protected

    def do_initialization
      C.LLVMInitializeFunctionPassManager(self) != 0
    end

    def do_finalization
      C.LLVMFinalizeFunctionPassManager(self) != 0
    end
  end
end
