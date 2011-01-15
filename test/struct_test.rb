require "test_helper"

class StructTestCase < Test::Unit::TestCase

  LLVM_UNPACKED = false
  LLVM_PACKED = true

  def setup
    LLVM.init_x86
  end

  def test_simple_struct
    struct = LLVM::Struct(LLVM::Int, LLVM::Float)
    assert_instance_of LLVM::Type, struct
  end

  def test_unpacked_constant_struct_from_size
    struct = LLVM::ConstantStruct.const(2, LLVM_UNPACKED) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
  end

  def test_unpacked_constant_struct_from_struct
    struct = LLVM::ConstantStruct.const([LLVM::Int(0), LLVM::Int(1)], LLVM_UNPACKED)
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
  end

  def test_packed_constant_struct_from_size
    struct = LLVM::ConstantStruct.const(2, LLVM_PACKED) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
  end

  def test_packed_constant_struct_from_struct
    struct = LLVM::ConstantStruct.const([LLVM::Int(0), LLVM::Int(1)], LLVM_PACKED)
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
  end

  def test_struct_values
    assert_equal 2 + 3, run_struct_values(2, 3).to_i
  end

  def test_struct_access
    assert_in_delta 2 + 3.3, run_struct_access(LLVM::Float, 2, 3.3).to_f, 0.001
  end

  def run_struct_values(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Struct(LLVM::Int, LLVM::Int))
      struct = builder.load(pointer)
      struct = builder.insert_value(struct, arguments.first, 0)
      struct = builder.insert_value(struct, arguments.last, 1)
      builder.ret(builder.add(builder.extract_value(struct, 0),
                              builder.extract_value(struct, 1)))
    end
  end

  def run_struct_access(return_type, value1, value2)
    run_function([LLVM::Int, LLVM::Float], [value1, value2], return_type) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Struct(LLVM::Float, LLVM::Struct(LLVM::Int, LLVM::Float), LLVM::Int))
      builder.store(arguments.first, builder.gep(pointer, [LLVM::Int(0), LLVM::Int32.from_i(1), LLVM::Int32.from_i(0)]))
      builder.store(arguments.last, builder.gep(pointer, [LLVM::Int(0), LLVM::Int32.from_i(1), LLVM::Int32.from_i(1)]))
      address1 = builder.gep(pointer, [LLVM::Int(0), LLVM::Int32.from_i(1), LLVM::Int32.from_i(0)])
      address2 = builder.gep(pointer, [LLVM::Int(0), LLVM::Int32.from_i(1), LLVM::Int32.from_i(1)])
      builder.ret(builder.fadd(builder.ui2fp(builder.load(address1), LLVM::Float), builder.load(address2)))
    end
  end

end
