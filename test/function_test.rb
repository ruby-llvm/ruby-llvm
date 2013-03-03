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

end
