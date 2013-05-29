require "test_helper"

class InstructionTestCase < Minitest::Test
  def setup
    LLVM.init_jit
    @module = LLVM::Module.new("InstructionTestCase")
  end

  def test_instruction
    fn = @module.functions.add("test_instruction", [LLVM::Double], LLVM::Double) do |fn, arg|
      fn.basic_blocks.append.build do |builder|
        builder.ret(
          builder.fadd(arg, LLVM.Double(3.0)))
      end
    end

    entry = fn.basic_blocks.entry

    inst1 = entry.instructions.first
    inst2 = entry.instructions.last

    assert_kind_of LLVM::Instruction, inst1
    assert_kind_of LLVM::Instruction, inst2

    assert_equal inst2, inst1.next
    assert_equal inst1, inst2.previous
    assert_equal entry, inst1.parent
    assert_equal entry, inst2.parent
  end
end


