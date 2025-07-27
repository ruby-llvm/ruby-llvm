# frozen_string_literal: true
# typed: true

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

  def test_empty_vector
    assert_raises(ArgumentError) do
      LLVM::ConstantVector.const(0)
    end

    assert_raises(ArgumentError) do
      LLVM::ConstantVector.const([])
    end
  end

  def test_constant_vector_from_size
    vector = LLVM::ConstantVector.const(2) { |i| LLVM::Int(i) }
    check_const_vector(vector)
  end

  def test_constant_vector_from_array
    vector = LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)])
    check_const_vector(vector)
  end

  def test_vector_elements
    assert_equal 2 + 3, run_vector_elements(2, 3).to_i
  end

  def test_vector_shuffle
    assert_equal 1 + 4, run_vector_shuffle(1, 2, 3, 4).to_i
  end

  def test_vector_gep
    run_function([LLVM::Int, LLVM::Int], [1, 2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)

      pointer = builder.alloca(LLVM::Vector(LLVM::Int, 2))
      assert_equal "  %3 = alloca <2 x i32>, align 8", pointer.to_s
      assert_equal :vector, pointer.allocated_type.kind
      assert_equal :pointer, pointer.type.kind

      pgep1 = builder.gep(pointer, [LLVM::Int(0), LLVM::Int(1)])
      assert_equal "  %4 = getelementptr <2 x i32>, ptr %3, i32 0, i32 1", pgep1.to_s

      array = builder.load(pointer)
      assert_equal :vector, array.type.kind
      assert_equal "  %5 = load <2 x i32>, ptr %3, align 8", array.to_s

      load2 = builder.load2(LLVM::Int, pgep1)
      assert_equal "  %6 = load i32, ptr %4, align 4", load2.to_s

      load = builder.load(pgep1)
      assert_equal "  %7 = load i32, ptr %4, align 4", load.to_s

      array = builder.insert_element(array, arguments.first, LLVM::Int32.from_i(0))
      assert_equal :vector, array.type.kind

      array = builder.insert_element(array, arguments.last, LLVM::Int32.from_i(1))
      assert_equal :vector, array.type.kind

      builder.ret(builder.add(builder.extract_element(array, LLVM::Int32.from_i(0)),
                              builder.extract_element(array, LLVM::Int32.from_i(1))))
    end
  end

  private

  def run_vector_elements(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      assert_equal "i32 %0", arguments.first.to_s
      assert_equal :integer, arguments.first.type.kind
      assert_equal "i32 %1", arguments.last.to_s
      assert_equal :integer, arguments.last.type.kind

      entry = function.basic_blocks.append
      builder.position_at_end(entry)

      pointer = builder.alloca(LLVM::Vector(LLVM::Int, 2))
      assert_equal :pointer, pointer.type.kind
      assert_equal :vector, pointer.allocated_type.kind
      assert_equal "  %3 = alloca <2 x i32>, align 8", pointer.to_s

      vector = builder.load(pointer)
      assert_equal :vector, vector.type.kind
      assert_equal "  %4 = load <2 x i32>, ptr %3, align 8", vector.to_s

      vector = builder.insert_element(vector, arguments.first, LLVM::Int32.from_i(0))
      assert_equal :vector, vector.type.kind

      vector = builder.insert_element(vector, arguments.last, LLVM::Int32.from_i(1))
      assert_equal :vector, vector.type.kind

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

  def check_const_vector(vector)
    assert_instance_of LLVM::ConstantVector, vector
    assert_equal 2, vector.size
    assert_equal "<2 x i32> <i32 0, i32 1>", vector.to_s

    assert_equal "i32 0", vector[0].to_s
    assert_equal :integer, vector[0].type.kind

    assert_equal :vector, vector.type.kind
    refute_predicate vector.type, :aggregate?
    assert_equal "<2 x i32>", vector.type.to_s
    assert_instance_of LLVM::Type, vector.type
    assert_equal "i32", vector.type.element_type.to_s
  end
end
