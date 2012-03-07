require "test_helper"

class GenericValueTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_from_i
    assert_equal 2, LLVM::GenericValue.from_i(2).to_i
    assert_equal 2 ,LLVM::GenericValue.from_i(2.2).to_i
  end

  def test_from_float
    assert_in_delta 2.2, LLVM::GenericValue.from_f(2.2).to_f, 1e-6
  end

  def test_from_double
    assert_in_delta 2.2, LLVM::GenericValue.from_d(2.2).to_f(LLVM::Double), 1e-6
  end

end
