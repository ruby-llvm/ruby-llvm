require 'llvm'
require 'llvm/core'
require 'llvm/transforms/builder_ffi'

module LLVM
  class PassManagerBuilder
    include PointerIdentity

    attr_reader :size_level
    attr_reader :opt_level
    attr_reader :unit_at_a_time
    attr_reader :unroll_loops
    attr_reader :simplify_lib_calls
    attr_reader :inliner_threshold

    def initialize
      @ptr = C.pass_manager_builder_create

      @size_level         = 0
      @opt_level          = 0
      @unit_at_a_time     = false
      @unroll_loops       = false
      @simplify_lib_calls = false
      @inliner_threshold  = 0
    end

    def dispose
      return if @ptr.nil?

      C.pass_manager_builder_dispose(@ptr)
      @ptr = nil
    end

    # Specify the basic optimization level.
    # @param [Integer] level 0 = -O0, 1 = -O1, 2 = -O2, 3 = -O3
    def opt_level=(level)
      @opt_level = level.to_i
      C.pass_manager_builder_set_opt_level(self, @opt_level)
    end

    # How much we're optimizing for size.
    # @param [Integer] level 0 = none, 1 = -Os, 2 = -Oz
    def size_level=(level)
      @size_level = level.to_i
      C.pass_manager_builder_set_size_level(self, @size_level)
    end

    # @param [Boolean] do_unit_at_a_time
    def unit_at_a_time=(do_unit_at_a_time)
      @unit_at_a_time = do_unit_at_a_time
      C.pass_manager_builder_set_disable_unit_at_a_time(self, flag(!@unit_at_a_time))
    end

    # @param [Boolean] do_unroll
    def unroll_loops=(do_unroll)
      @unroll_loops = do_unroll
      C.pass_manager_builder_set_disable_unroll_loops(self, flag(!@unroll_loops))
    end

    # @param [Boolean] do_simplify_lib_calls
    def simplify_lib_calls=(do_simplify_lib_calls)
      @simplify_lib_calls = do_simplify_lib_calls
      C.pass_manager_builder_set_disable_simplify_lib_calls(self, flag(!@simplify_lib_calls))
    end

    # @param [Integer] threshold 0 = -O1, 225 = -O2, 275 = -O3
    def inliner_threshold=(threshold)
      @inliner_threshold = threshold
      C.pass_manager_builder_use_inliner_with_threshold(self, @inliner_threshold)
    end

    # Populate a pass manager.
    # @param [PassManager, FunctionPassManager] pass_manager
    def build(pass_manager)
      case pass_manager
      when FunctionPassManager
        C.pass_manager_builder_populate_function_pass_manager(self, pass_manager)

      when PassManager
        C.pass_manager_builder_populate_module_pass_manager(self, pass_manager)
      end
    end

    # Populate an LTO pass manager.
    # @param [PassManager] pass_manager
    def build_with_lto(pass_manager, internalize=false, run_inliner=false)
      if pass_manager.is_a?(FunctionPassManager)
        raise ArgumentError, "FunctionPassManager does not support LTO"
      end

      # Add flag() when the header gets fixed and has LLVMBool
      C.pass_manager_builder_populate_lto_pass_manager(self,
            pass_manager, internalize, run_inliner)
    end

    private

    def flag(boolean)
      boolean ? 1 : 0
    end
  end
end
