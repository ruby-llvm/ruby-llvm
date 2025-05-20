# frozen_string_literal: true
# typed: true

require "test_helper"
require "llvm/core"
require 'llvm/transforms/ipo'
require 'llvm/core/pass_manager'

class IPOTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_gdce
    mod = LLVM::Module.new('test')

    fn1 = mod.functions.add("fn1", [], LLVM.Void) do |fn|
      fn.linkage = :internal
      fn.basic_blocks.append.build do |builder|
        builder.ret_void
      end
    end

    fn2 = mod.functions.add("fn2", [], LLVM.Void) do |fn|
      fn.linkage = :internal
      fn.basic_blocks.append.build do |builder|
        builder.ret_void
      end
    end

    main = mod.functions.add("main", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        builder.call(fn1)
        builder.ret_void
      end
    end

    fns = mod.functions.to_a
    assert_includes fns, fn1
    assert_includes fns, fn2
    assert_includes fns, main

    # optimize
    engine = LLVM::MCJITCompiler.new(mod)
    pass_builder = LLVM::PassBuilder.new

    pass_builder.gdce!
    pass_builder.run(mod, engine.target_machine)

    fns = mod.functions.to_a
    assert_includes fns, fn1
    refute_includes fns, fn2, 'fn2 should be eliminated'
    assert_includes fns, main
  end
end
