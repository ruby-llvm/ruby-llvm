require "test_helper"

class ArrayTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_constant_array_from_size
    array = LLVM::ConstantArray.const(LLVM::Int, 2) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantArray, array
    assert_equal 2, array.operands.size
  end

  def test_constant_array_from_array
    array = LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int(0), LLVM::Int(1)])
    assert_instance_of LLVM::ConstantArray, array
    assert_equal 2, array.operands.size
  end

  def test_array_values
    assert_equal 2 + 3, run_array_values(2, 3).to_i
  end

  def run_array_values(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Array(LLVM::Int, 2))
      array = builder.load(pointer)
      array = builder.insert_value(array, arguments.first, 0)
      array = builder.insert_value(array, arguments.last, 1)
      builder.ret(builder.add(builder.extract_value(array, 0),
                              builder.extract_value(array, 1)))
    end
  end

end
