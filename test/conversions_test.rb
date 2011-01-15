require "test_helper"

class ConversionsTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_trunc_to
    integer_conversion_assertion(:trunc, LLVM::Int32.from_i(257), LLVM::Int8, LLVM_UNSIGNED, 1)
    integer_conversion_assertion(:trunc, LLVM::Int32.from_i(123), LLVM::Int1, LLVM_UNSIGNED, 1)
    integer_conversion_assertion(:trunc, LLVM::Int32.from_i(122), LLVM::Int1, LLVM_UNSIGNED, 0)
  end

  def test_zext_to
    integer_conversion_assertion(:zext, LLVM::Int16.from_i(257), LLVM::Int32, LLVM_UNSIGNED, 257)
  end

  def test_sext_to
    integer_conversion_assertion(:sext, LLVM::Int1.from_i(1), LLVM::Int32, LLVM_SIGNED, -1)
    integer_conversion_assertion(:sext, LLVM::Int8.from_i(-1), LLVM::Int16, LLVM_UNSIGNED, 65535)
  end

  def test_fptrunc_to
    float_conversion_assertion(:fp_trunc, LLVM::Double(123.0), LLVM::Float, 123.0)
  end

  def test_fpext_to
    float_conversion_assertion(:fp_ext, LLVM::Float(123.0), LLVM::Double, 123.0)
    float_conversion_assertion(:fp_ext, LLVM::Float(123.0), LLVM::Float, 123.0)
  end

  def test_fptoui_to
    different_type_assertion(:fp2ui, LLVM::Double(123.3), LLVM::Int32, :integer, 123)
    different_type_assertion(:fp2ui, LLVM::Double(0.7), LLVM::Int32, :integer, 0)
    different_type_assertion(:fp2ui, LLVM::Double(1.7), LLVM::Int32, :integer, 1)
  end

  def test_fptosi_to
    different_type_assertion(:fp2si, LLVM::Double(-123.3), LLVM::Int32, :integer, -123)
    different_type_assertion(:fp2si, LLVM::Double(0.7), LLVM::Int32, :integer, 0)
    different_type_assertion(:fp2si, LLVM::Double(1.7), LLVM::Int32, :integer, 1)
  end

  def test_uitofp_to
    different_type_assertion(:ui2fp, LLVM::Int32.from_i(257), LLVM::Float, :float, 257.0)
    different_type_assertion(:ui2fp, LLVM::Int8.from_i(-1), LLVM::Double, :float, 255.0)
  end

  def test_sitofp_to
    different_type_assertion(:si2fp, LLVM::Int32.from_i(257), LLVM::Float, :float, 257.0)
    different_type_assertion(:si2fp, LLVM::Int8.from_i(-1), LLVM::Double, :float, -1.0)
  end

  def test_bitcast_to
    different_type_assertion(:bit_cast, LLVM::Int8.from_i(255), LLVM::Int8, :integer, -1)
  end

  def integer_conversion_assertion(operation, operand, return_type, signed, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    assert_equal expected_result, result.to_i(signed)
  end

  def float_conversion_assertion(operation, operand, return_type, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    assert_in_delta expected_result, result.to_f(return_type), 0.001
  end

  def different_type_assertion(operation, operand, return_type, assertion_type, expected_result)
    result = run_conversion_operation(operation, operand, return_type)
    if assertion_type == :integer
      assert_equal expected_result, result.to_i
    else
      assert_in_delta expected_result, result.to_f(return_type), 0.001
    end
  end

  def run_conversion_operation(operation, operand, return_type)
    run_function([], [], return_type) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(builder.send(operation, operand, return_type))
    end
  end

end
