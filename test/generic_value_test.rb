require "test_helper"

class GenericValueTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_from_it
    assert_equal 2, LLVM::GenericValue(2).to_i
    assert_equal 0 ,LLVM::GenericValue(2.2).to_i
  end

  def test_from_float
    assert_in_delta 2.2, LLVM::GenericValue(2.2).to_f, 0.01
  end

end
