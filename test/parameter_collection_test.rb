# frozen_string_literal: true

require "test_helper"

class ParameterCollectionTestCase < Minitest::Test
  def setup
    @mod = LLVM::Module.new('test')
    @fun = @mod.functions.add('fun', [LLVM::Int, LLVM::Int], LLVM::Int)
    @fun.params[0].name = 'foo'
    @fun.params[1].name = 'bar'
  end

  def test_positive_index_in_range
    assert_equal 'foo', @fun.params[0].name
    assert_equal 'bar', @fun.params[1].name
  end

  def test_negative_index_in_range
    assert_equal 'foo', @fun.params[-2].name
    assert_equal 'bar', @fun.params[-1].name
  end

  def test_positive_index_out_of_range
    assert_nil @fun.params[2]
  end

  def test_negative_index_out_of_range
    assert_nil @fun.params[-3]
  end
end
