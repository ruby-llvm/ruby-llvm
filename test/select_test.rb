require "test_helper"

class SelectTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_select
    assert_equal 0, select_function(1).to_i
    assert_equal 1, select_function(0).to_i
  end

  def select_function(value)
    run_function([LLVM::Int1], [value], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(builder.select(arguments.first, LLVM::Int(0), LLVM::Int(1)))
    end
  end

end
