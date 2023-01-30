# frozen_string_literal: true

require "test_helper"

class StructTestCase < Minitest::Test

  LLVM_UNPACKED = false
  LLVM_PACKED = true

  def setup
    LLVM.init_jit
  end

  def test_simple_struct
    struct = LLVM::Struct(LLVM::Int, LLVM::Float)
    assert_instance_of LLVM::StructType, struct
    assert_equal 2, struct.element_types.size
    assert_equal LLVM::Int.type, struct.element_types[0]
    assert_equal LLVM::Float.type, struct.element_types[1]
    assert_predicate struct, :aggregate?
    assert_equal "{ i32, float }", struct.to_s
  end

  def test_empty_struct
    struct = LLVM::Struct()
    assert_instance_of LLVM::StructType, struct
    assert_equal 0, struct.element_types.size
    assert_predicate struct, :aggregate?
    refute_predicate struct, :opaque?
    assert_equal "{}", struct.to_s
  end

  def test_opaque_struct
    struct = LLVM::Struct("mystery")
    assert_instance_of LLVM::StructType, struct
    assert_equal 0, struct.element_types.size
    assert_predicate struct, :aggregate?
    assert_predicate struct, :opaque?
    assert_equal "%mystery = type opaque", struct.to_s
  end

  def test_existing_struct
    first_struct = LLVM::Struct("thing")
    assert_equal "%thing = type opaque", first_struct.to_s
    same_name_struct = LLVM::Struct("thing")
    assert_equal "%thing.0 = type opaque", same_name_struct.to_s

    find_first_struct = LLVM::Type.named("thing")
    assert_equal "%thing = type opaque", find_first_struct.to_s
    find_same_namestruct = LLVM::Type.named("thing.0")
    assert_equal "%thing.0 = type opaque", find_same_namestruct.to_s
  end

  def test_named_struct
    struct = LLVM::Struct(LLVM::Int, LLVM::Float, "struct100")
    assert_instance_of LLVM::StructType, struct
    assert_equal "struct100", struct.name
    assert_predicate struct, :aggregate?
    assert_equal "%struct100 = type { i32, float }", struct.to_s
  end

  def test_deferred_element_type_setting
    struct = LLVM::Struct("struct200")
    struct.element_types = [LLVM::Int, LLVM::Float]
    assert_equal 2, struct.element_types.size
    assert_predicate struct, :aggregate?
    assert_equal "%struct200 = type { i32, float }", struct.to_s
  end

  def test_unpacked_constant_struct_from_size
    struct = LLVM::ConstantStruct.const(2, LLVM_UNPACKED) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
    assert_predicate struct.type, :aggregate?
    assert_equal "{ i32, i32 } { i32 0, i32 1 }", struct.to_s
  end

  def test_unpacked_constant_struct_from_struct
    struct = LLVM::ConstantStruct.const([LLVM::Int(0), LLVM::Int(1)], LLVM_UNPACKED)
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
    assert_predicate struct.type, :aggregate?
    assert_equal "{ i32, i32 } { i32 0, i32 1 }", struct.to_s
    assert_equal "i32 0", struct[0].to_s
    assert_equal :integer, struct[0].type.kind
  end

  def test_packed_constant_struct_from_size
    struct = LLVM::ConstantStruct.const(2, LLVM_PACKED) { |i| LLVM::Int(i) }
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
    assert_predicate struct.type, :aggregate?
    assert_equal "<{ i32, i32 }> <{ i32 0, i32 1 }>", struct.to_s
  end

  def test_packed_constant_struct_from_struct
    struct = LLVM::ConstantStruct.const([LLVM::Int(0), LLVM::Int(1)], LLVM_PACKED)
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 2, struct.operands.size
    assert_predicate struct.type, :aggregate?
    assert_equal "<{ i32, i32 }> <{ i32 0, i32 1 }>", struct.to_s
    assert_equal "i32 0", struct[0].to_s
    assert_equal :integer, struct[0].type.kind
  end

  def test_constant_named_struct
    struct_ty = LLVM::Struct(LLVM::Int, "struct300")
    struct = LLVM::ConstantStruct.named_const(struct_ty, [ LLVM::Int(1) ])
    assert_instance_of LLVM::ConstantStruct, struct
    assert_equal 1, struct.operands.size
    assert_equal struct_ty, struct.type
    assert_predicate struct_ty, :aggregate?
    assert_equal "%struct300 { i32 1 }", struct.to_s
    assert_equal "i32 1", struct[0].to_s
    assert_equal :integer, struct[0].type.kind
  end

  def test_struct_values
    assert_equal 2 + 3, run_struct_values(2, 3).to_i
  end

  def test_struct_access
    assert_in_delta 2 + 3.3, run_struct_access(LLVM::Float, 2, 3.3).to_f, 0.001
  end

  def test_struct_access_gep
    assert_in_delta 2 + 3.3, run_struct_access_gep(LLVM::Float, 2, 3.3).to_f, 0.001
  end

  private

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
      builder.ret(builder.fadd(builder.ui2fp(builder.load2(LLVM::Int32, address1), LLVM::Float), builder.load2(LLVM::Float, address2)))
    end
  end

  def run_struct_access_gep(return_type, value1, value2)
    run_function([LLVM::Int, LLVM::Float], [value1, value2], return_type) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.alloca(LLVM::Struct(LLVM::Int, LLVM::Float))

      builder.store(arguments.first, builder.struct_gep(pointer, 0))
      builder.store(arguments.last, builder.struct_gep(pointer, 1))

      address1 = builder.struct_gep(pointer, 0)
      address2 = builder.struct_gep(pointer, 1)
      builder.ret(builder.fadd(builder.ui2fp(builder.load2(LLVM::Int32, address1), LLVM::Float), builder.load2(LLVM::Float, address2)))
    end
  end

end
