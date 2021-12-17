require "test_helper"

class IntegerTestCase < Minitest::Test

  def test_const_zext
    assert i = LLVM::Int8.from_i(-1)
    assert_equal 'i8 -1', i.to_s
    assert_equal :integer, i.type.kind
    assert_equal 8, i.type.width
    assert zext = i.zext(LLVM::Int64)
    assert_equal 'i64 255', zext.to_s
    assert_equal :integer, zext.type.kind
    assert_equal 64, zext.type.width
  end

  def test_const_sext
    assert i = LLVM::Int8.from_i(-1)
    assert_equal 'i8 -1', i.to_s
    assert_equal :integer, i.type.kind
    assert_equal 8, i.type.width
    assert sext = i.sext(LLVM::Int64)
    assert_equal 'i64 -1', sext.to_s
    assert_equal :integer, sext.type.kind
    assert_equal 64, sext.type.width
  end
end
