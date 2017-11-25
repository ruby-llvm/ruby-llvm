require "test_helper"

class DoubleTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_double
    mod	= LLVM::Module.new("Double Test")
    mod.functions.add(:sin, [LLVM::Double], LLVM::Double)

    builder = LLVM::Builder.new

    mod.functions.add('test', [LLVM::Double], LLVM::Double) do |fun, p0|
      p0.name = 'x'

      bb = fun.basic_blocks.append
      builder.position_at_end(bb)

      builder.ret(builder.fadd(p0, LLVM::Double(1.0)))
    end

    engine = LLVM::MCJITCompiler.new(mod)

    arg	= 5.0
    result = engine.run_function(mod.functions["test"], arg)
    assert_equal arg+1, result.to_f(LLVM::Double)

# TODO: fix this
#    assert_in_delta(Math.sin(1.0),
#      engine.run_function(mod.functions["sin"], 1.0).to_f(LLVM::Double),
#      1e-10)
  end
end
