require "test_helper"

class ModuleTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_simple_module
    assert_equal 1, simple_function().to_i
  end

  def simple_function
    define_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(LLVM::Int(1))
    end
  end

end
