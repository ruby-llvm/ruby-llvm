# frozen_string_literal: true

require "test_helper"

class InstructionTestCase < Minitest::Test # rubocop:disable Metrics/ClassLength
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

  def test_exactract_value_with_bad_params
    vec = LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)])
    arr = LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int(0), LLVM::Int(1)])
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.extract_value(LLVM::Struct(LLVM::Int64, LLVM::Int64), 0)
        end
        assert_raises(ArgumentError) do
          builder.extract_value(nil, 0)
        end
        assert_raises(ArgumentError) do
          builder.extract_value(vec, 0)
        end
        assert_raises(ArgumentError) do
          builder.extract_value(arr, nil)
        end
        assert_raises(ArgumentError) do
          builder.extract_value(arr, -1)
        end
      end
    end
  end

  def test_exactract_element_with_bad_params
    vec = LLVM::ConstantVector.const([LLVM::Int(0), LLVM::Int(1)])
    arr = LLVM::ConstantArray.const(LLVM::Int, [LLVM::Int(0), LLVM::Int(1)])
    @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        assert_raises(ArgumentError) do
          builder.extract_element(LLVM::Struct(LLVM::Int64, LLVM::Int64), LLVM::Int32.from_i(0))
        end
        assert_raises(ArgumentError) do
          builder.extract_element(nil, LLVM::Int32.from_i(0))
        end
        assert_raises(ArgumentError) do
          builder.extract_element(arr, LLVM::Int32.from_i(0))
        end
        assert_raises(ArgumentError) do
          builder.extract_element(vec, nil)
        end
        assert_raises(ArgumentError) do
          builder.extract_element(vec, 0)
        end
      end
    end
  end

  def test_types_alloca_load_store
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        alloca = builder.alloca(LLVM::Int, "test")
        assert_equal :pointer, alloca.type.kind
        assert_equal LLVM::Type(LLVM::Int), alloca.allocated_type
        load = builder.load(alloca)
        assert_equal LLVM::Type(LLVM::Int), load.type
      end
    end
  end

  # some builder instructions do not return instruction values
  # int math with constants returns constants, or poison
  def test_builder_returns_non_instruction_ints
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        ops = [:add, :sub, :mul]
        prefixes = ['', :nsw_, :nuw_]

        skip "TODO"

        prefixes.product(ops).map(&:join).each do |op|
          assert inst = builder.send(op, LLVM::Int32.from_i(0), LLVM::Int32.from_i(0))
          assert_instance_of LLVM::Int32, inst
          assert_equal "i32 0", inst.to_s
        end

        [:sdiv, :exact_sdiv, :udiv].each do |op|
          assert inst = builder.send(op, LLVM::Int32.from_i(0), LLVM::Int32.from_i(1))
          assert_instance_of LLVM::Int32, inst
          assert_equal "i32 0", inst.to_s

          assert inst = builder.send(op, LLVM::Int32.from_i(0), LLVM::Int32.from_i(0))
          assert_instance_of LLVM::Poison, inst
          assert_equal "i32 poison", inst.to_s
        end
      end
    end
  end

  # some builder instructions do not return instruction values
  # float math with constants returns constants
  def test_builder_returns_non_instruction_floats
    fn = @module.functions.add("test_instruction", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        [:fadd, :fsub, :fmul].each do |op|
          assert inst = builder.send(op, LLVM::Float.from_f(0), LLVM::Float.from_f(0))
          assert_instance_of LLVM::Float, inst
          assert_equal "float 0.000000e+00", inst.to_s
        end

        [:fdiv, :frem].each do |op|
          assert inst = builder.send(op, LLVM::Float.from_f(0), LLVM::Float.from_f(1))
          assert_instance_of LLVM::Float, inst
          assert_equal "float 0.000000e+00", inst.to_s

          # 0 / 0 == nan
          assert inst = builder.send(op, LLVM::Float.from_f(0), LLVM::Float.from_f(0))
          assert_instance_of LLVM::Float, inst
          assert_equal 'float 0x7FF8000000000000', inst.to_s
        end
        builder.ret
      end
    end
    assert_predicate fn, :valid?
  end

  def test_fdiv_nan_inf
    fn = @module.functions.add("test_fdiv", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        # fdiv 1 / 0 == +inf
        assert inst = builder.fdiv(LLVM::Float.from_f(1), LLVM::Float.from_f(0))
        assert_instance_of LLVM::Float, inst
        assert_equal 'float 0x7FF0000000000000', inst.to_s

        # fdiv -1 / 0 == -inf
        assert inst = builder.fdiv(LLVM::Float.from_f(-1), LLVM::Float.from_f(0))
        assert_instance_of LLVM::Float, inst
        assert_equal 'float 0xFFF0000000000000', inst.to_s

        builder.ret
      end
    end
    assert_predicate fn, :valid?
  end

  def test_frem_nan_inf
    fn = @module.functions.add("test_frem", [], LLVM.Void) do |fn|
      fn.basic_blocks.append.build do |builder|
        # frem 1 / 0 == nan
        assert inst = builder.frem(LLVM::Float.from_f(1), LLVM::Float.from_f(0))
        assert_instance_of LLVM::Float, inst
        assert_equal 'float 0x7FF8000000000000', inst.to_s

        # rem -1 / 0 == nan
        assert inst = builder.frem(LLVM::Float.from_f(-1), LLVM::Float.from_f(0))
        assert_instance_of LLVM::Float, inst
        assert_equal 'float 0x7FF8000000000000', inst.to_s

        builder.ret
      end
    end
    assert_predicate fn, :valid?
  end

  def test_fneg
    fn = @module.functions.add("test_fneg", [LLVM::Double], LLVM::Double) do |fn, param|
      fn.basic_blocks.append.build do |builder|
        builder.ret builder.fneg param
      end
    end
    assert_predicate fn, :valid?
  end

end
