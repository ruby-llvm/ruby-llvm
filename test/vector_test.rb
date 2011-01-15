require "test_helper"

class VectorTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_vector_elements
    assert_equal 5, run_vector_elements().to_i
  end

  def run_vector_elements
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Vector(LLVM::Int, 2))
      vector = builder.load(pointer)
      vector = builder.insert_element(vector, LLVM::Int(2), LLVM::Int32.from_i(0))
      vector = builder.insert_element(vector, LLVM::Int(3), LLVM::Int32.from_i(1))
      builder.ret(builder.add(builder.extract_element(vector, LLVM::Int32.from_i(0)),
                              builder.extract_element(vector, LLVM::Int32.from_i(1))))
    end
  end

end
