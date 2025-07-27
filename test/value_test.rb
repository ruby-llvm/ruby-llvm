# frozen_string_literal: true
# typed: true

require "test_helper"

class ValueTestCase < Minitest::Test
  extend Minitest::Spec::DSL

  def test_is_null
    assert_predicate LLVM::Int32.null, :null?
    assert_predicate LLVM::Int32.from_i(0), :null?
    refute_predicate LLVM::Int32.from_i(1), :null?
  end

  def test_undef
    assert_predicate LLVM::Int32.undef, :undef?
    refute_predicate LLVM::Int32.from_i(1), :undef?
    assert_predicate LLVM::Int32.undef, :undefined?
    refute_predicate LLVM::Int32.from_i(1), :undefined?
  end

  def test_poison
    assert_predicate LLVM::Int32.poison, :poison?
    refute_predicate LLVM::Int32.from_i(1), :poison?
  end

  def test_constant
    assert_predicate LLVM::Int32.null, :constant?
    assert_predicate LLVM::Int32.undef, :constant?
    assert_predicate LLVM::Int32.poison, :constant?
    assert_predicate LLVM::Int32.from_i(1), :constant?
  end

  def test_kind
    assert_equal :const_int, LLVM::Int32.null.kind
    assert_equal :const_fp, LLVM::Float.type.null.kind
    assert_equal :const_fp, LLVM::Double.type.null.kind
    assert_equal :pointer, LLVM.Pointer.kind
    assert_equal :const_null, LLVM.Pointer.null.kind
    assert_equal :void, LLVM.Void.kind
    assert_equal :poison, LLVM::Int32.poison.kind
    assert_equal :undef, LLVM::Int32.undef.kind
    assert_equal :struct, LLVM::Struct(LLVM::Int, LLVM::Float).kind

    assert_equal :const_aggregregate_zero, LLVM::ConstantArray.const(LLVM::Int, []).kind
    assert_equal :const_aggregregate_zero, LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int.null]).kind
    assert_equal :const_aggregregate_zero, LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int.from_i(0)]).kind
    assert_equal :const_data_array, LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int.from_i(1)]).kind

    assert_equal :const_data_vector, LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)]).kind
  end

  TO_S_TESTS = [
    [LLVM::FALSE, 'i1 false'],
    [LLVM::TRUE, 'i1 true'],
    [LLVM::Int1.from_i(0), 'i1 false'],
    [LLVM::Int1.from_i(-1), 'i1 true'],
    [LLVM::Int1.from_i(1), 'i1 poison'],

    [LLVM::Constant.null(LLVM::Int32), 'i32 0'],
    [LLVM::Constant.undef(LLVM::Int32), 'i32 undef'],
    [LLVM::Constant.poison(LLVM::Int32), 'i32 poison'],

    [LLVM::ConstantExpr.null(LLVM::Int32), 'i32 0'],
    [LLVM::ConstantExpr.undef(LLVM::Int32), 'i32 undef'],
    [LLVM::ConstantExpr.poison(LLVM::Int32), 'i32 poison'],

    [LLVM::Int32.type.null, 'i32 0'],
    [LLVM::Int32.type.undef, 'i32 undef'],
    [LLVM::Int32.type.poison, 'i32 poison'],

    [LLVM::Int32.null, 'i32 0'],
    [LLVM::Int32.undef, 'i32 undef'],
    [LLVM::Int32.poison, 'i32 poison'],
    [LLVM::Int32.null_pointer, 'i32 null'],

    [LLVM::Constant.null(LLVM::Pointer(LLVM::Int32)), 'ptr null'],
    [LLVM::Constant.undef(LLVM::Pointer(LLVM::Int32)), 'ptr undef'],
    [LLVM::Constant.poison(LLVM::Pointer(LLVM::Int32)), 'ptr poison'],

    [LLVM::ConstantExpr.null(LLVM::Pointer(LLVM::Int32)), 'ptr null'],
    [LLVM::ConstantExpr.undef(LLVM::Pointer(LLVM::Int32)), 'ptr undef'],
    [LLVM::ConstantExpr.poison(LLVM::Pointer(LLVM::Int32)), 'ptr poison'],

    [LLVM::Pointer(LLVM::Int8).null, 'ptr null'],
    [LLVM::Pointer(LLVM::Int8).undef, 'ptr undef'],
    [LLVM::Pointer(LLVM::Int8).poison, 'ptr poison'],

    [LLVM::Pointer().null, 'ptr null'],
    [LLVM::Pointer().undef, 'ptr undef'],
    [LLVM::Pointer().poison, 'ptr poison'],

    [LLVM::Constant.null(LLVM.Pointer), 'ptr null'],
    [LLVM::Constant.undef(LLVM.Pointer), 'ptr undef'],
    [LLVM::Constant.poison(LLVM.Pointer), 'ptr poison'],

    [LLVM::ConstantExpr.null(LLVM.Pointer), 'ptr null'],
    [LLVM::ConstantExpr.undef(LLVM.Pointer), 'ptr undef'],
    [LLVM::ConstantExpr.poison(LLVM.Pointer), 'ptr poison'],

    [LLVM.Pointer.null, 'ptr null'],
    [LLVM.Pointer.undef, 'ptr undef'],
    [LLVM.Pointer.poison, 'ptr poison'],

    [LLVM::Type.pointer.null, 'ptr null'],
    [LLVM::Type.pointer.undef, 'ptr undef'],
    [LLVM::Type.pointer.poison, 'ptr poison'],

    [LLVM::Int32.parse("42"), 'i32 42'],
    [LLVM::Int8.parse("127"), 'i8 127'],
    [LLVM::Int8.parse("-128"), 'i8 -128'],
    [LLVM::Int8.parse("128"), 'i8 poison'],
    [LLVM::Int8.parse("-129"), 'i8 poison'],

    [LLVM::Int32.parse("256").int_to_ptr, 'ptr inttoptr (i32 256 to ptr)'],
    [LLVM::Int32.parse("256").int_to_ptr.ptr_to_int(LLVM::Int64), 'i64 ptrtoint (ptr inttoptr (i32 256 to ptr) to i64)'],

    [LLVM::Float.parse("0"), "float 0.000000e+00"],
    [LLVM::Double.parse("0"), "double 0.000000e+00"],
  ].freeze

  describe "LLVM::Value#to_s" do
    TO_S_TESTS.each do |(value, string)|
      it "should return '#{string}'" do
        assert_kind_of LLVM::Constant, value
        assert_kind_of LLVM::Value, value
        assert_equal string, value.to_s
      end
    end
  end
end
