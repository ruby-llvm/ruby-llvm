require "test_helper"
require "llvm/core"
require 'llvm/transforms/ipo'
require 'llvm/core/pass_manager'

class IPOTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
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
    assert fns.include?(fn1)
    assert fns.include?(fn2)
    assert fns.include?(main)

    # optimize
    engine = LLVM::JITCompiler.new(mod)
    passm  = LLVM::PassManager.new(engine)

    passm.gdce!
    passm.run(mod)

    fns = mod.functions.to_a
    assert fns.include?(fn1)
    assert !fns.include?(fn2), 'fn2 should be eliminated'
    assert fns.include?(main)
  end
end
