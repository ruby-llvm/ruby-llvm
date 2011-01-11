require "test_helper"

class ComparisonsTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_integer_comparison
    define_integer_comparison_assertion(:eq, 1, 1, true, 1)
    define_integer_comparison_assertion(:ne, 1, 1, true, 0)
    define_integer_comparison_assertion(:ugt, 2, 2, false, 0)
    define_integer_comparison_assertion(:uge, 2, 1, false, 1)
    define_integer_comparison_assertion(:ult, 1, 1, false, 0)
    define_integer_comparison_assertion(:ule, 1, 2, false, 1)
    define_integer_comparison_assertion(:sgt, -2, 2, true, 0)
    define_integer_comparison_assertion(:sge, -2, 1, true, 0)
    define_integer_comparison_assertion(:slt, -1, 2, true, 1)
    define_integer_comparison_assertion(:sle, -1, 2, true, 1)
  end

  def test_float_comparison
    define_float_comparison_assertion(:oeq, 1.0, 1.0, 1)
    define_float_comparison_assertion(:one, 1.0, 1.0, 0)
    define_float_comparison_assertion(:ogt, 2.0, 2.0, 0)
    define_float_comparison_assertion(:oge, 2.0, 1.0, 1)
    define_float_comparison_assertion(:olt, 1.0, 1.0, 0)
    define_float_comparison_assertion(:ole, 1.0, 2.0, 1)
    define_float_comparison_assertion(:ord, 1.0, 2.0, 1)
    define_float_comparison_assertion(:ueq, 1.0, 1.0, 1)
    define_float_comparison_assertion(:une, 1.0, 1.0, 0)
    define_float_comparison_assertion(:ugt, 2.0, 2.0, 0)
    define_float_comparison_assertion(:uge, 2.0, 1.0, 1)
    define_float_comparison_assertion(:ult, 1.0, 1.0, 0)
    define_float_comparison_assertion(:ule, 1.0, 2.0, 1)
    define_float_comparison_assertion(:uno, 1.0, 2.0, 0)
  end

  def define_integer_comparison_assertion(operation, operand1, operand2, signed, expected_result)
    result = define_comparison_operation(:icmp,
                                         operation,
                                         LLVM::Int.from_i(operand1, signed),
                                         LLVM::Int.from_i(operand2, signed),
                                         LLVM::Int1).to_i(false)
    assert_equal expected_result, result
  end

  def define_float_comparison_assertion(operation, operand1, operand2, expected_result)
    result = define_comparison_operation(:fcmp,
                                         operation,
                                         LLVM::Float(operand1),
                                         LLVM::Float(operand2),
                                         LLVM::Int1).to_i(false)
    assert_equal expected_result, result
  end

  def define_comparison_operation(comparison_operation, comparison_operator,
                                  operand1, operand2, return_type)
    define_function([], [], return_type) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(builder.send(comparison_operation, comparison_operator, operand1, operand2))
    end
  end

end
