# frozen_string_literal: true

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
    assert_in_delta 2.2, LLVM::GenericValue.from_f(2.2).to_f, 1e-6
  end

  def test_from_double
    assert_in_delta 2.2, LLVM::GenericValue.from_d(2.2).to_f(LLVM::Double), 1e-6
  end

  def test_from_bool
    assert_equal true, LLVM::GenericValue.from_b(true).to_b
    assert_equal false, LLVM::GenericValue.from_b(false).to_b
  end

end
