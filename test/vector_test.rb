require "test_helper"

class VectorTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_all_ones_vector
    assert_raise(NotImplementedError) do
      LLVM::ConstantVector.all_ones
    end
  end

  def test_constant_vector_from_size
    vector = LLVM::ConstantVector.const(2) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantVector, vector
    assert_equal 2, vector.operands.size
  end

  def test_constant_vector_from_array
    vector = LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)])
    assert_instance_of LLVM::ConstantVector, vector
    assert_equal 2, vector.operands.size
  end

  def test_vector_elements
    assert_equal 5, run_vector_elements(2, 3).to_i
  end

  def run_vector_elements(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Vector(LLVM::Int, 2))
      vector = builder.load(pointer)
      vector = builder.insert_element(vector, arguments.first, LLVM::Int32.from_i(0))
      vector = builder.insert_element(vector, arguments.last, LLVM::Int32.from_i(1))
      builder.ret(builder.add(builder.extract_element(vector, LLVM::Int32.from_i(0)),
                              builder.extract_element(vector, LLVM::Int32.from_i(1))))
    end
  end

end
