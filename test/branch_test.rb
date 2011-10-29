require "test_helper"

class BranchTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_branching
    assert_equal 0, direct_jump_function().to_i
    assert_equal 0, conditional_jump_function().to_i
    assert_equal 0, switched_jump_function().to_i
  end

  def direct_jump_function
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      branch_1 = function.basic_blocks.append
      branch_2 = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.br(branch_2)
      builder.position_at_end(branch_1)
      builder.ret(LLVM::Int(1))
      builder.position_at_end(branch_2)
      builder.ret(LLVM::Int(0))
    end
  end

  def conditional_jump_function
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      branch_1 = function.basic_blocks.append
      branch_2 = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.cond(builder.icmp(:eq, LLVM::Int(1), LLVM::Int(2)), branch_1, branch_2)
      builder.position_at_end(branch_1)
      builder.ret(LLVM::Int(1))
      builder.position_at_end(branch_2)
      builder.ret(LLVM::Int(0))
    end
  end

  def switched_jump_function
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      branch_1 = function.basic_blocks.append
      branch_2 = function.basic_blocks.append
      builder.position_at_end(entry)
      switch = builder.switch(LLVM::Int(1), branch_1, 1)
      switch.add_case(LLVM::Int(1), branch_2)
      builder.position_at_end(branch_1)
      builder.ret(LLVM::Int(1))
      builder.position_at_end(branch_2)
      builder.ret(LLVM::Int(0))
    end
  end

end
