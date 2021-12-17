# frozen_string_literal: true

require "test_helper"

class VectorTestCase < Minitest::Test

  def setup
    LLVM.init_jit
  end

  def test_all_ones_vector
    assert_raises(NotImplementedError) do
      LLVM::ConstantVector.all_ones
    end
  end

  def test_constant_vector_from_size
    vector = LLVM::ConstantVector.const(2) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantVector, vector
    assert_equal 2, vector.size
  end

  def test_constant_vector_from_array
    vector = LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)])
    assert_instance_of LLVM::ConstantVector, vector
    assert_equal 2, vector.size
  end

  def test_vector_elements
    assert_equal 2 + 3, run_vector_elements(2, 3).to_i
  end

  def test_vector_shuffle
    assert_equal 1 + 4, run_vector_shuffle(1, 2, 3, 4).to_i
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

  def run_vector_shuffle(*values)
    run_function([LLVM::Int, LLVM::Int, LLVM::Int, LLVM::Int], values, LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      vector1 = builder.load(builder.alloca(LLVM::Vector(LLVM::Int, 2)))
      vector1 = builder.insert_element(vector1, arguments[0], LLVM::Int32.from_i(0))
      vector1 = builder.insert_element(vector1, arguments[1], LLVM::Int32.from_i(1))
      vector2 = builder.load(builder.alloca(LLVM::Vector(LLVM::Int, 2)))
      vector2 = builder.insert_element(vector2, arguments[2], LLVM::Int32.from_i(0))
      vector2 = builder.insert_element(vector2, arguments[3], LLVM::Int32.from_i(1))
      vector3 = builder.shuffle_vector(vector1, vector2, LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(3)]))
      builder.ret(builder.add(builder.extract_element(vector3, LLVM::Int32.from_i(0)),
                              builder.extract_element(vector3, LLVM::Int32.from_i(1))))
    end
  end

end
