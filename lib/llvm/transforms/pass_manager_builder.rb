# frozen_string_literal: true
# typed: true

require 'llvm'
require 'llvm/core'

module LLVM
  class PassManagerBuilder
    include PointerIdentity

    attr_reader :size_level, :opt_level, :unit_at_a_time, :unroll_loops, :simplify_lib_calls, :inliner_threshold

    def initialize
      @ptr = nil

      @size_level         = 0
      @opt_level          = 0
      @unit_at_a_time     = false
      @unroll_loops       = false
      @simplify_lib_calls = false
      @inliner_threshold  = 0
    end

    def dispose; end

    # rubocop:disable Style/TrivialAccessors

    # Specify the basic optimization level.
    # @param [Integer] level 0 = -O0, 1 = -O1, 2 = -O2, 3 = -O3
    def opt_level=(level)
      @opt_level = level.to_i
    end

    # How much we're optimizing for size.
    # @param [Integer] level 0 = none, 1 = -Os, 2 = -Oz
    def size_level=(level)
      @size_level = level.to_i
    end

    # @param [Boolean] do_unit_at_a_time
    def unit_at_a_time=(do_unit_at_a_time)
      @unit_at_a_time = do_unit_at_a_time
    end

    # @param [Boolean] do_unroll
    def unroll_loops=(do_unroll)
      @unroll_loops = do_unroll
    end

    # @param [Boolean] do_simplify_lib_calls
    def simplify_lib_calls=(do_simplify_lib_calls)
      @simplify_lib_calls = do_simplify_lib_calls
    end

    # @param [Integer] threshold 0 = -O1, 225 = -O2, 275 = -O3
    def inliner_threshold=(threshold)
      @inliner_threshold = threshold
    end

    # rubocop:enable Style/TrivialAccessors

    # Populate a pass manager.
    # @param [PassManager, FunctionPassManager] pass_manager
    def build(_pass_manager)
      raise DeprecationError
    end

    # Populate an LTO pass manager.
    # @param [PassManager] pass_manager
    def build_with_lto(_pass_manager, _internalize = false, _run_inliner = false) # rubocop:disable Style/OptionalBooleanParameter
      raise DeprecationError
    end

    private

    def flag(boolean)
      boolean ? 1 : 0
    end
  end
end
