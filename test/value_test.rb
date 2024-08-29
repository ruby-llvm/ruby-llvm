# frozen_string_literal: true

require "test_helper"

class ValueTestCase < Minitest::Test

  extend Minitest::Spec::DSL

  TO_S_TESTS = [
    [LLVM::FALSE, 'i1 false'],
    [LLVM::TRUE, 'i1 true'],

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
