# frozen_string_literal: true

require "test_helper"

class TypeTestCase < Minitest::Test

  extend Minitest::Spec::DSL

  def test_element_type
    pointer = LLVM.Pointer(LLVM::Int32.type)
    pointee = pointer.element_type

    assert_equal :pointer, pointer.kind
    assert_equal :void, pointee.kind
  end

  def test_element_type_unsupported
    assert_raises do
      LLVM.Void.element_type
    end
  end

  def test_element_type_array
    array = LLVM::Array(LLVM::Int, 2)
    assert_equal :integer, array.element_type.kind
  end

  def test_element_type_vector
    vector = LLVM::Vector(LLVM::Int, 2)
    assert_equal :integer, vector.element_type.kind
  end

  def test_size
    assert_equal "i64 ptrtoint (ptr getelementptr (float, ptr null, i32 1) to i64)", LLVM::Type.float.size.to_s
    assert_equal "i64 ptrtoint (ptr getelementptr (double, ptr null, i32 1) to i64)", LLVM::Type.double.size.to_s
    assert_equal "i64 ptrtoint (ptr getelementptr (i42, ptr null, i32 1) to i64)", LLVM::Type.integer(42).size.to_s
  end

  def test_align
    assert_equal "i64 ptrtoint (ptr getelementptr ({ i1, i64 }, ptr null, i64 0, i32 1) to i64)", LLVM::Int64.align.to_s
  end

  def test_from_i
    assert_raises(ArgumentError) do
      LLVM::Type.integer(42).from_i(0, 42)
    end

    # TODO: add these tests
    # assert_equal 'i8 -42"', LLVM::Int8.from_i(128, true).to_s
    # assert_equal 'i8 -42"', LLVM::Int8.from_i(128, false).to_s
  end

  TO_S_TESTS = [
    [LLVM.Struct(), '{}'],
    [LLVM.Struct("test"), '%test = type opaque'],
    [LLVM.Struct(LLVM::Int32, LLVM::Int32), '{ i32, i32 }'],
    [LLVM.Struct(LLVM::Int32, LLVM::Int32, "s1"), '%s1 = type { i32, i32 }'],
    [LLVM::Type.struct([LLVM::Int32, LLVM::Int32], true), '<{ i32, i32 }>'],
    [LLVM::Type.struct([LLVM::Int32, LLVM::Int32], true, "s2"), '%s2 = type <{ i32, i32 }>'],
    [LLVM::Type.struct([], false), '{}'],
    [LLVM::Type.struct([], true), '<{}>'],

    [LLVM.Array(LLVM::Int8), '[0 x i8]'],
    [LLVM.Array(LLVM::Int8, 42), '[42 x i8]'],
    [LLVM::Type.array(LLVM::Int1), '[0 x i1]'],
    [LLVM::Type.array(LLVM::Int1, 42), '[42 x i1]'],

    [LLVM.Vector(LLVM::Int8, 42), '<42 x i8>'],
    [LLVM::Type.vector(LLVM::Int1, 42), '<42 x i1>'],

    [LLVM::Type.void, 'void'],
    [LLVM::Type.label, 'label'],
    [LLVM::Type.x86_mmx, 'x86_mmx'],
    [LLVM::Type.x86_amx, 'x86_amx'],
    [LLVM.Void, 'void'],

    [LLVM.Pointer(LLVM::Int8), 'ptr'],
    [LLVM::Type.pointer(LLVM::Int1), 'ptr'],
    [LLVM::Type.pointer(LLVM::Int1, 1), 'ptr addrspace(1)'],
    [LLVM.Pointer(), 'ptr'],
    [LLVM::Type.pointer, 'ptr'],
    [LLVM::Type.ptr, 'ptr'],
    [LLVM::Type.ptr(1), 'ptr addrspace(1)'],

    [LLVM.Function([LLVM::Int8], LLVM.Void), 'void (i8)'],
    [LLVM.Function([LLVM::Int8], LLVM::Int8), 'i8 (i8)'],
    [LLVM.Function([], LLVM::Int8), 'i8 ()'],
    [LLVM.Function([], LLVM.Void), 'void ()'],
    [LLVM::Type.function([LLVM::Int1], LLVM.Void), 'void (i1)'],
    [LLVM::Type.function([LLVM::Int1], LLVM::Int1), 'i1 (i1)'],
    [LLVM::Type.function([], LLVM::Int1), 'i1 ()'],
    [LLVM::Type.function([], LLVM.Void), 'void ()'],
    [LLVM::Type.function([], LLVM::Int1, varargs: true), 'i1 (...)'],
    [LLVM::Type.function([], LLVM.Void, varargs: true), 'void (...)'],

    [LLVM.Struct(LLVM::Int32, LLVM::Type.array(LLVM::Float)), '{ i32, [0 x float] }'],

    [LLVM::Int32.pointer, 'ptr'],
    [LLVM::Int32.pointer(42), 'ptr addrspace(42)'],

    # breaks struct_Test
    # [LLVM::Type.opaque_struct("mystery"), '%mystery = type opaque'],
  ].freeze

  describe "LLVM::Type#to_s" do
    TO_S_TESTS.each do |(type, string)|
      it "should return '#{string}'" do
        assert_kind_of LLVM::Type, type
        assert_equal string, type.to_s
      end
    end
  end

  describe 'void type' do
    it 'should have kind :void' do
      type = LLVM.Void
      assert_equal :void, type.kind
    end
  end

  describe 'label type' do
    it 'should have kind :void' do
      type = LLVM::Type.label
      assert_equal :label, type.kind
    end
  end

end
