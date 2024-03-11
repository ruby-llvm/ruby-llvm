# frozen_string_literal: true

require "test_helper"

class DoubleTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_const_double
    assert d = LLVM::Double.from_f(-1)
    assert_equal "double -1.000000e+00", d.to_s
    assert_equal :double, d.type.kind
    assert_predicate d, :constant?
  end

  def test_const_double_bitcast
    assert_equal "i64 0", LLVM::Double.from_f(0).bitcast_to(LLVM::Int64).to_s
    assert_equal "i64 4607182418800017408", LLVM::Double.from_f(1).bitcast_to(LLVM::Int64).to_s
    assert_equal "i64 -4616189618054758400", LLVM::Double.from_f(-1).bitcast_to(LLVM::Int64).to_s
  end

  def test_const_double_null
    assert_equal "double 0.000000e+00", LLVM::Constant.null(LLVM::Double).to_s
  end

  def test_const_double_to_i
    assert_equal "i64 0", LLVM::Double.from_f(0.0).to_i(LLVM::Int64).to_s
    assert_equal "i64 1", LLVM::Double.from_f(1.0).to_i(LLVM::Int64).to_s
    assert_equal "i64 -1", LLVM::Double.from_f(-1.0).to_i(LLVM::Int64).to_s

    assert_equal "i32 0", LLVM::Float.from_f(0.0).to_i(LLVM::Int32).to_s
    assert_equal "i32 1", LLVM::Float.from_f(1.0).to_i(LLVM::Int32).to_s
    assert_equal "i32 -1", LLVM::Float.from_f(-1.0).to_i(LLVM::Int32).to_s

    assert_equal "i64 9223371487098961920", LLVM::Float.from_f(9_223_371_761_976_868_351.0).to_i(LLVM::Int64).to_s
    assert_equal "i64 poison", LLVM::Float.from_f(9_223_371_761_976_868_352.0).to_i(LLVM::Int64).to_s

    assert_equal "i64 9223371761976867840", LLVM::Double.from_f(9_223_371_761_976_868_351.0).to_i(LLVM::Int64).to_s
    assert_equal "i64 9223372036854774784", LLVM::Double.from_f(9_223_372_036_854_775_295.0).to_i(LLVM::Int64).to_s
    assert_equal "i64 poison", LLVM::Double.from_f(9_223_372_036_854_775_296.0).to_i(LLVM::Int64).to_s
  end

  def test_ext_trunc
    assert_equal LLVM.Float(0), LLVM.Double(0).trunc(LLVM::Float)
    assert_equal LLVM.Double(0), LLVM.Float(0).ext(LLVM::Double)
  end

  def test_fp_trunc_overflows_to_inf
    assert_equal LLVM.Float(Float::INFINITY), LLVM.Double(1e300).trunc(LLVM::Float)
  end

  def test_const_fneg
    assert_equal LLVM.Double(-1), -LLVM.Double(1)
  end

  def test_const_math
    assert_equal LLVM.Double(2), LLVM.Double(1) + LLVM.Double(1)
    assert_equal LLVM.Double(2), LLVM.Double(3) - LLVM.Double(1)
    assert_equal LLVM.Double(2), LLVM.Double(2) * LLVM.Double(1)
    assert_equal LLVM.Double(2), LLVM.Double(2) / LLVM.Double(1)
  end

  def test_const_rem
    assert_equal LLVM.Double(0), LLVM.Double(0).rem(LLVM.Double(1))
    assert_equal LLVM.Double(-3), LLVM.Double(-11).rem(LLVM.Double(-4))
  end

  def test_double
    mod = LLVM::Module.new("Double Test")
    mod.functions.add(:sin, [LLVM::Double], LLVM::Double)

    builder = LLVM::Builder.new

    mod.functions.add('test', [LLVM::Double], LLVM::Double) do |fun, p0|
      p0.name = 'x'

      bb = fun.basic_blocks.append
      builder.position_at_end(bb)

      builder.ret(builder.fadd(p0, LLVM::Double(1.0)))
    end

    engine = LLVM::MCJITCompiler.new(mod)

    arg = 5.0
    result = engine.run_function(mod.functions["test"], arg)
    assert_equal arg + 1, result.to_f(LLVM::Double)

    skip 'MCJIT cannot find external function sin'

    assert actual = engine.run_function(mod.functions["sin"], 1.0).to_f(LLVM::Double)
    assert_in_delta(Math.sin(1.0), actual, 1e-10)
  end
end
