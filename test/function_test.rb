# frozen_string_literal: true

require "test_helper"
require "llvm/core"


def with_function(arguments, retty, &block)
  mod = LLVM::Module.new('test')
  fun = mod.functions.add('fun', arguments, retty)
  block.yield(fun)
  mod.dispose
end

class FunctionTest < Minitest::Test

  def test_type
    with_function [], LLVM.Void do |fun|
      type = fun.type

      assert_instance_of LLVM::Type, type
      assert_equal :pointer,  type.kind
      assert_equal :function, type.element_type.kind
    end
  end

  def test_function_type
    with_function [], LLVM.Void do |fun|
      type = fun.function_type

      assert_instance_of LLVM::FunctionType, type
      assert_equal :function, type.kind
    end
  end

  def helper_test_attribute(name, attribute_id)
    with_function [], LLVM.Void do |fun|
      assert_equal 0, fun.attribute_count
      assert_equal [], fun.attributes

      fun.add_attribute(name)
      assert_equal 1, fun.attribute_count
      assert_equal [attribute_id], fun.attributes

      assert_equal false, fun.verify

      fun.remove_attribute(name)
      assert_equal 0, fun.attribute_count
      assert_equal [], fun.attributes

      assert_equal false, fun.verify
    end
  end

  def test_add_attribute_old_name
    helper_test_attribute(:no_unwind_attribute, 35)
  end

  def test_add_attribute_new_name
    helper_test_attribute(:nounwind, 35)
    helper_test_attribute(:readnone, 42)
    helper_test_attribute(:readonly, 43)
    helper_test_attribute(:willreturn, 64)
  end

end

class FunctionTypeTest < Minitest::Test

  def test_return_type
    with_function [], LLVM.Void do |fun|
      type = fun.function_type
      assert_equal LLVM.Void, type.return_type
    end

    with_function [], LLVM::Int32 do |fun|
      retty = fun.function_type.return_type

      assert_kind_of LLVM::IntType, retty
      assert_equal 32, retty.width
    end
  end

  def test_argument_types
    with_function [], LLVM.Void do |fun|
      types = fun.function_type.argument_types
      assert_equal [], types
    end

    with_function [LLVM::Int32], LLVM.Void do |fun|
      types = fun.function_type.argument_types
      assert_equal 1, types.size
      a1 = types[0]
      assert_kind_of LLVM::IntType, a1
      assert_equal 32, a1.width
    end
  end

  def test_vararg
    with_function [], LLVM.Void do |fun|
      type = fun.function_type
      assert !type.vararg?, 'should be false'
    end
  end

end
