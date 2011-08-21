require "test_helper"

class ReturnTestCase < Test::Unit::TestCase
  def test_two_returns
    value = run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret LLVM::Int(1)
      builder.ret LLVM::Int(2)
    end
    assert_equal 1, value.to_i
  end
end
