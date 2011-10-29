require "test_helper"

class BasicTestCase < Test::Unit::TestCase

  def test_llvm_initialization
    assert_nothing_raised do
      LLVM.init_x86
    end
  end

end
