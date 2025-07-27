# frozen_string_literal: true
# typed: true

require "test_helper"

class GenericValueTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_from_i
    assert_equal 2, LLVM::GenericValue.from_i(2).to_i
    assert_equal 2, LLVM::GenericValue.from_i(2.2).to_i
  end

  def test_from_float
    assert_in_delta 2.2, LLVM::GenericValue.from_f(2.2).to_f, 1e-7
    assert_in_delta 2**127, LLVM::GenericValue.from_f(2**127).to_f, 0.0
  end

  def test_from_double
    assert_in_delta 2.2, LLVM::GenericValue.from_d(2.2).to_d, 0.0
    assert_in_delta 2**1023, LLVM::GenericValue.from_d(2**1023).to_d, 0.0
    one_third = Rational(1, 3).to_f
    assert_in_delta one_third, LLVM::GenericValue.from_d(one_third).to_d, 0.0
  end

  def test_from_bool
    assert LLVM::GenericValue.from_b(true).to_b
    refute LLVM::GenericValue.from_b(false).to_b
  end

  def test_from_b_to_i
    assert_equal(-1, LLVM::GenericValue.from_b(true).to_i)
    assert_equal(0, LLVM::GenericValue.from_b(false).to_i)
  end

  def test_from_i_to_b
    refute LLVM::GenericValue.from_i(0).to_b
    [1, -1].each do |i|
      assert LLVM::GenericValue.from_i(i).to_b
    end
  end

  def test_from_i_to_f
    assert_in_delta(0.0, LLVM::GenericValue.from_i(0).to_f)
    assert_in_delta(0.0, LLVM::GenericValue.from_i(256).to_f)
  end

  def test_from_f_to_i
    assert_equal(0, LLVM::GenericValue.from_f(0.0).to_i)
    assert_equal(0, LLVM::GenericValue.from_f(256.0).to_i)
  end

  def test_make_void
    assert_raises(ArgumentError) do
      LLVM.make_generic_value(LLVM.void, nil)
    end
  end
end
