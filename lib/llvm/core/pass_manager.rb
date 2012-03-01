module LLVM
  # The PassManager runs a queue of passes on a module. See
  # http://llvm.org/docs/Passes.html for the list of available passes.
  class PassManager
    # Creates a new pass manager on the given ExecutionEngine.
    def initialize(execution_engine)
      ptr = C.create_pass_manager()
      C.add_target_data(
        C.get_execution_engine_target_data(execution_engine), ptr)
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
      C.run_pass_manager(self, mod) != 0
    end
    
    # Disposes the pass manager.
    def dispose
      return if @ptr.nil?
      do_finalization
      C.dispose_pass_manager(@ptr)
      @ptr = nil
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
      ptr = C.create_function_pass_manager_for_module(mod)
      C.add_target_data(
        C.get_execution_engine_target_data(execution_engine), ptr)
      @ptr = ptr
    end

    # Run the pass queue on the given function.
    # @param [LLVM::Function]
    # @return [true, false] indicates whether the function was modified.
    def run(fn)
      C.run_function_pass_manager(self, fn) != 0
    end

    protected

    def do_initialization
      C.initialize_function_pass_manager(self) != 0
    end

    def do_finalization
      C.finalize_function_pass_manager(self) != 0
    end
  end
end
