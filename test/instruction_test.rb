# frozen_string_literal: true

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

  def test_ret_with_non_value
    @module.functions.add("test_instruction", [LLVM::Double], LLVM::Double) do |fn, _arg|
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.ret(LLVM.Void)
        end
        assert_raises(ArgumentError) do
          builder.ret(100)
        end
        assert_raises(ArgumentError) do
          builder.ret(10.5)
        end
      end
    end
  end

  # nil is a valid pointer for use with ret instruction
  def test_ret_with_nil
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        builder.ret(nil)
      end
    end
    assert_match(/ret void/, fn.to_s)
  end

  def test_ret_void
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build(&:ret_void)
    end
    assert_match(/ret void/, fn.to_s)
  end

  def test_ret_with_default_param
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build(&:ret)
    end
    assert_match(/ret void/, fn.to_s)
  end

  def test_br_with_non_block
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.br(LLVM::Int64.from_i(0))
        end

        assert_raises(ArgumentError) do
          builder.br(nil)
        end
      end
    end
  end

  def test_cond_with_non_blocks
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      true_branch = fn.basic_blocks.append("true_branch")
      false_branch = fn.basic_blocks.append("false_branch")
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.cond(LLVM::Int1.from_i(1), true_branch, nil)
        end

        assert_raises(ArgumentError) do
          builder.cond(LLVM::Int1.from_i(0), nil, false_branch)
        end
      end
    end
  end

  def test_cond_with_bad_condition
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      true_branch = fn.basic_blocks.append("true_branch")
      false_branch = fn.basic_blocks.append("false_branch")
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.cond(nil, true_branch, false_branch)
        end

        assert_raises(ArgumentError) do
          builder.cond(LLVM::Int64.from_i(0), true_branch, false_branch)
        end

        builder.cond(true, true_branch, false_branch)
        builder.cond(false, true_branch, false_branch)
      end
    end
  end

  def test_cond_with_good_condition
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      true_branch = fn.basic_blocks.append("true_branch")
      false_branch = fn.basic_blocks.append("false_branch")
      fn.basic_blocks.append.build do |builder|
        builder.cond(LLVM::Int1.from_i(1), true_branch, false_branch)
        builder.cond(LLVM::Int1.from_i(0), true_branch, false_branch)
        builder.cond(true, true_branch, false_branch)
        builder.cond(false, true_branch, false_branch)
        test = builder.icmp(:eq, LLVM::Int64.from_i(0), LLVM::Int64.from_i(0))
        builder.cond(test, true_branch, false_branch)
      end
    end
  end

end
