require 'test_helper'

class MCJITTestCase < Minitest::Test
  def setup
    LLVM.init_jit(true)
  end

  def test_simple_function
    mod = LLVM::Module.new("square")
    mod.functions.add(:square, [LLVM::Int], LLVM::Int) do |fun, x|
      fun.basic_blocks.append.build do |builder|
        n = builder.mul(x, x)
        builder.ret(n)
      end
    end

    mod.verify!

    engine = LLVM::MCJITCompiler.new(mod, :opt_level => 0)

    result = engine.run_function(mod.functions['square'], 5)
    assert_equal 25, result.to_i
  end
end
