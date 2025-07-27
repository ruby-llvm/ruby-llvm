# frozen_string_literal: true
# typed: true

require "test_helper"
require "llvm/core"

class FunctionTest < Minitest::Test
  def test_to_s
    with_function [], LLVM.Void do |fun|
      assert_equal "declare void @fun()\n", fun.to_s
    end
  end

  def test_type
    with_function [], LLVM.Void do |fun|
      type = fun.type
      assert_instance_of LLVM::FunctionType, type
      assert_equal 'void ()', type.to_s
      assert_equal :function, type.kind
      assert_equal :function, type.element_type.kind
    end
  end

  def test_function_type
    with_function [], LLVM.Void do |fun|
      type = fun.function_type

      assert_instance_of LLVM::FunctionType, type
      assert_equal 'void ()', type.to_s
      assert_equal :function, type.kind
      assert_equal :function, type.element_type.kind
      assert_equal LLVM.Void, type.return_type
      assert_equal :void, type.return_type.kind
    end
  end

  def test_function_type_pointer
    with_function [], LLVM.Pointer(LLVM::Int8) do |fun|
      assert_equal :function, fun.type.kind
      assert_equal :function, fun.type.element_type.kind
      assert_equal :function, fun.function_type.kind
      assert_equal :pointer, fun.function_type.return_type.kind
    end
  end

  def helper_test_attribute(name, attribute_id)
    with_function [], LLVM.Void do |fun|
      assert_equal 0, fun.attribute_count
      assert_empty fun.attributes

      fun.add_attribute(name)
      assert_equal 1, fun.attribute_count
      assert_equal [LLVM::Attribute.new(name)], fun.attributes
      assert_equal [attribute_id], fun.attributes.map(&:kind_id)

      assert_predicate fun, :valid?

      fun.remove_attribute(name)
      assert_equal 0, fun.attribute_count
      assert_empty fun.attributes

      assert_predicate fun, :valid?
    end
  end

  def test_add_attribute_old_name
    helper_test_attribute(:no_unwind_attribute, 42)
  end

  def test_add_attribute_new_name
    helper_test_attribute(:mustprogress, 19)
    helper_test_attribute(:nounwind, 42)
    helper_test_attribute(:willreturn, 77)
  end

  def test_invalid_function
    with_function [], LLVM.Void do |fun|
      assert_equal 0, fun.basic_blocks.size
      assert entry = fun.basic_blocks.append

      entry.build do |builder|
        builder.ret(LLVM::Int(1))
      end
      assert_equal(1, LLVM::C.verify_function(fun, :return_status))
      refute_predicate fun, :valid?
      refute_predicate fun, :verify
    end
  end
end

class FunctionTypeTest < Minitest::Test
  def test_return_type_void
    with_function [], LLVM.Void do |fun|
      retty = fun.function_type.return_type
      assert_equal LLVM.Void, retty
      assert_equal 'void', retty.to_s
    end
  end

  def test_return_type_i32
    with_function [], LLVM::Int32 do |fun|
      retty = fun.function_type.return_type

      assert_kind_of LLVM::IntType, retty
      assert_equal 32, retty.width
      assert_equal 'i32', retty.to_s
    end
  end

  def test_argument_types
    with_function [], LLVM.Void do |fun|
      types = fun.function_type.argument_types
      assert_empty types
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
      refute_predicate type, :vararg?, 'should be false'
    end
  end
end
