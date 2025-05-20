# frozen_string_literal: true
# typed: true

require "test_helper"

class PhiTest < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_phi
    assert_equal 1, run_phi_function(0).to_i
    assert_equal 0, run_phi_function(1).to_i
  end

  def run_phi_function(argument)
    run_function([LLVM::Int], argument, LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      block1 = function.basic_blocks.append
      block2 = function.basic_blocks.append
      exit = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.cond(builder.icmp(:eq, arguments.first, LLVM::Int(0)), block1, block2)
      builder.position_at_end(block1)
      result1 = builder.add(arguments.first, LLVM::Int(1))
      builder.br(exit)
      builder.position_at_end(block2)
      result2 = builder.sub(arguments.first, LLVM::Int(1))
      builder.br(exit)
      builder.position_at_end(exit)
      builder.ret(builder.phi(LLVM::Int,
                              block1 => result1,
                              block2 => result2))
    end
  end
end
