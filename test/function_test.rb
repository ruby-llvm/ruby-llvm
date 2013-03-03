require "test_helper"
require "llvm/core"


def with_function(arguments, retty, &block)
  mod = LLVM::Module.new('test')
  fun = mod.functions.add('fun', arguments, retty)
  block.yield(fun)
  mod.dispose
end

class FunctionTest < Test::Unit::TestCase

  def test_type
    with_function [], LLVM.Void do |fun|
      type = fun.type
      assert_not_nil type
      assert_instance_of LLVM::Type, type
      assert_equal :pointer,  type.kind
      assert_equal :function, type.element_type.kind
    end
  end

  def test_function_type
    with_function [], LLVM.Void do |fun|
      type = fun.function_type
      assert_not_nil type
      assert_instance_of LLVM::FunctionType, type
      assert_equal :function, type.kind
    end
  end

end

class FunctionTypeTest < Test::Unit::TestCase

  def test_return_type
    with_function [], LLVM.Void do |fun|
      type = fun.function_type
      assert_equal LLVM.Void, type.return_type
    end

    with_function [], LLVM::Int32 do |fun|
      retty = fun.function_type.return_type

      assert_not_nil retty
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
