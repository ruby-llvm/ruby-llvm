require "test_helper"

class TypeTestCase < Test::Unit::TestCase

  def test_element_type
    pointer = LLVM.Pointer(LLVM::Int32.type)  
    pointee = pointer.element_type

    assert_equal :pointer, pointer.kind
    assert_equal :integer, pointee.kind

    assert_nil pointee.element_type
  end

end
