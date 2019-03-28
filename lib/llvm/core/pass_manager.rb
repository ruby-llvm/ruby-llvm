module LLVM
  # The PassManager runs a queue of passes on a module. See
  # http://llvm.org/docs/Passes.html for the list of available passes.
  class PassManager
    # Creates a new pass manager.
    #
    # @param [LLVM::ExecutionEngine, LLVM::TargetMachine] machine
    def initialize(machine = nil)
      if !machine.nil?
        warn("[DEPRECATION] PassManager.new should be called without parameters")
      end
      @ptr = C.create_pass_manager()
    end

    # @private
    def to_ptr
      @ptr
    end

    # Append a pass to the pass queue.
    #
    # @param  [Symbol] name
    # @return [LLVM::PassManager]
    def <<(name)
      send(:"#{name}!")

      self
    end

    # Run the pass queue on the given module.
    #
    # @param  [LLVM::Module] mod
    # @return [true, false] Indicates whether the module was modified.
    def run(mod)
      C.run_pass_manager(self, mod) != 0
    end

    # Disposes the pass manager.
    def dispose
      return if @ptr.nil?

      finalize

      C.dispose_pass_manager(@ptr)
      @ptr = nil
    end

    protected

    def finalize
    end
  end

  class FunctionPassManager < PassManager
    # Creates a new function pass manager.
    #
    # @param [LLVM::ExecutionEngine, LLVM::TargetMachine] machine
    # @param [LLVM::Module] mod
    def initialize(machine, mod)
      @ptr = C.create_function_pass_manager_for_module(mod)
      C.add_target_data(machine.data_layout, @ptr)

      C.initialize_function_pass_manager(self) != 0
    end

    # Run the pass queue on the given function.
    #
    # @param  [LLVM::Function] fn
    # @return [true, false] indicates whether the function was modified.
    def run(fn)
      C.run_function_pass_manager(self, fn) != 0
    end

    protected

    def finalize
      C.finalize_function_pass_manager(self) != 0
    end
  end
end
