# frozen_string_literal: true

require "test_helper"

class ArrayTestCase < Minitest::Test
  def test_constant_array_from_size
    array = LLVM::ConstantArray.const(LLVM::Int, 2) { |i| LLVM::Int(i) }
    check_constant_array(array)
  end

  def test_constant_array_from_array
    array = LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int(0), LLVM::Int(1)])
    check_constant_array(array)
  end

  def test_constant_empty_array_from_size
    array = LLVM::ConstantArray.const(LLVM::Int, 0) {} # rubocop:disable Lint/EmptyBlock
    empty_array_check(array)
  end

  def test_constant_empty_array_from_array
    array = LLVM::ConstantArray.const(LLVM::Int, [])
    empty_array_check(array)
  end

  def test_array_values
    assert_equal 2 + 3, run_array_values(2, 3).to_i
  end

  def test_array_gep
    run_function([LLVM::Int, LLVM::Int], [1, 2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)

      pointer = builder.alloca(LLVM::Array(LLVM::Int, 2))
      assert_equal "  %3 = alloca [2 x i32], align 4", pointer.to_s
      assert_equal :array, pointer.allocated_type.kind
      assert_equal :pointer, pointer.type.kind

      pgep1 = builder.gep(pointer, [LLVM::Int(0), LLVM::Int(1)])
      assert_equal "  %4 = getelementptr [2 x i32], ptr %3, i32 0, i32 1", pgep1.to_s

      array = builder.load(pointer)
      assert_equal :array, array.type.kind
      assert_equal "  %5 = load [2 x i32], ptr %3, align 4", array.to_s

      load2 = builder.load2(LLVM::Int, pgep1)
      assert_equal "  %6 = load i32, ptr %4, align 4", load2.to_s

      load = builder.load(pgep1)
      assert_equal "  %7 = load i32, ptr %4, align 4", load.to_s

      array = builder.insert_value(array, arguments.first, 0)
      assert_equal :array, array.type.kind

      array = builder.insert_value(array, arguments.last, 1)
      assert_equal :array, array.type.kind

      builder.ret(builder.add(builder.extract_value(array, 0),
                              builder.extract_value(array, 1)))
    end
  end

  private

  def setup
    LLVM.init_jit
  end

  def run_array_values(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      assert_equal "i32 %0", arguments.first.to_s
      assert_equal :integer, arguments.first.type.kind
      assert_equal "i32 %1", arguments.last.to_s
      assert_equal :integer, arguments.last.type.kind

      entry = function.basic_blocks.append
      builder.position_at_end(entry)

      pointer = builder.alloca(LLVM::Array(LLVM::Int, 2))
      assert_equal "  %3 = alloca [2 x i32], align 4", pointer.to_s
      assert_equal :array, pointer.allocated_type.kind
      assert_equal :pointer, pointer.type.kind

      array = builder.load(pointer)
      assert_equal :array, array.type.kind
      assert_equal "  %4 = load [2 x i32], ptr %3, align 4", array.to_s

      array = builder.insert_value(array, arguments.first, 0)
      assert_equal :array, array.type.kind

      array = builder.insert_value(array, arguments.last, 1)
      assert_equal :array, array.type.kind

      builder.ret(builder.add(builder.extract_value(array, 0),
                              builder.extract_value(array, 1)))
    end
  end

  def check_constant_array(array)
    assert_instance_of LLVM::ConstantArray, array
    assert_equal 2, array.size
    assert_equal "[2 x i32] [i32 0, i32 1]", array.to_s

    assert_equal "i32 0", array[0].to_s
    assert_equal :integer, array[0].type.kind

    assert_equal :array, array.type.kind
    assert_predicate array.type, :aggregate?
    assert_equal "[2 x i32]", array.type.to_s
    assert_instance_of LLVM::Type, array.type
    assert_equal "i32", array.type.element_type.to_s
  end

  def empty_array_check(array)
    assert_instance_of LLVM::ConstantArray, array
    assert_equal 0, array.size
    assert_predicate array.type, :aggregate?
    assert_equal "[0 x i32] zeroinitializer", array.to_s
  end
end
