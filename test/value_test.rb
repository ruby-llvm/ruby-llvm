# frozen_string_literal: true

require "test_helper"

class ValueTestCase < Minitest::Test

  extend Minitest::Spec::DSL

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
