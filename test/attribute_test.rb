# frozen_string_literal: true

require "test_helper"

class AttributeTestCase < Minitest::Test
  ATTRIBUTE_KINDS = [
    :readnone,
    :readonly,
    :willreturn,
    :nounwind,
    :mustprogress,
  ].freeze

  def test_create_enums
    ATTRIBUTE_KINDS.each do |attr_name|
      attr = LLVM::Attribute.enum(attr_name)
      assert_equal attr_name, attr.kind.to_sym
      assert_instance_of LLVM::Attribute, attr
      assert_predicate attr, :enum?
      refute_predicate attr, :string?
      refute_predicate attr, :type?
      assert_equal attr_name.to_s, attr.inspect
      assert_equal attr_name.to_s, attr.to_s
      assert_equal LLVM::Attribute.new(attr_name), attr
    end
  end

  def test_function_readnone
    attr = LLVM::Attribute.enum(:readnone)
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr)
      assert_equal(['readnone'], fun.attributes.map(&:to_s))
      assert_equal "; Function Attrs: readnone\ndeclare void @fun() #0\n", fun.to_s
      assert_includes fun.attributes, attr
    end
  end

  def test_function_memory
    63.times do |index|
      attr = LLVM::Attribute.enum(:memory, index)
      with_function [], LLVM.Void do |fun|
        fun.add_attribute(attr)
        expected = "; Function Attrs: #{attr}\ndeclare void @fun() #0\n"
        assert_equal(expected, fun.to_s)
      end
    end
  end

  def test_function_memory_none
    expected = "; Function Attrs: memory(none)\ndeclare void @fun() #0\n"
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr_memory(0))
      assert_equal(expected, fun.to_s)
      assert_predicate(fun, :readnone?)
      refute_predicate(fun, :readonly?)
      refute_predicate(fun, :writeonly?)
    end
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr_memory(64))
      assert_equal(expected, fun.to_s)
      assert_predicate(fun, :readnone?)
      refute_predicate(fun, :readonly?)
      refute_predicate(fun, :writeonly?)
    end
  end

  def test_function_memory_read
    expected = "; Function Attrs: memory(read)\ndeclare void @fun() #0\n"
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr_memory(21))
      assert_equal(expected, fun.to_s)
      assert_predicate(fun, :readonly?)
      refute_predicate(fun, :readnone?)
      refute_predicate(fun, :writeonly?)
    end
  end

  def test_function_memory_write
    expected = "; Function Attrs: memory(write)\ndeclare void @fun() #0\n"
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr_memory(42))
      assert_equal(expected, fun.to_s)
      assert_predicate(fun, :writeonly?)
      refute_predicate(fun, :readonly?)
      refute_predicate(fun, :readnone?)
    end
  end

  def test_function_memory_readwrite
    expected = "; Function Attrs: memory(readwrite)\ndeclare void @fun() #0\n"
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr_memory(63))
      assert_equal(expected, fun.to_s)
    end
  end

  def test_last_enum
    assert_equal 89, LLVM::Attribute.last_enum
  end

  def test_create_string
    k = "unsafe-fp-math"
    v = "false"
    attr = LLVM::Attribute.string(k, v)
    assert_instance_of LLVM::Attribute, attr
    assert_predicate attr, :string?
    refute_predicate attr, :enum?
    refute_predicate attr, :type?
    assert_equal v, attr.value
    assert_equal k, attr.kind
    assert_equal '"unsafe-fp-math"="false"', attr.inspect
  end

  def test_attribute_equality
    assert_equal attr_readnone, attr_readnone
    assert_equal attr_memnone, "memory(none)" # rubocop:disable Minitest/LiteralAsActualArgument
    assert_equal "memory(none)", attr_memnone.to_s
  end

  def test_readnone
    assert_predicate attr_readnone, :readnone?
    refute_predicate attr_readnone, :readonly?
    refute_predicate attr_readnone, :writeonly?

    assert_predicate attr_memnone, :readnone?
    refute_predicate attr_memnone, :readonly?
    refute_predicate attr_memnone, :writeonly?
  end

  def test_readonly
    assert_predicate attr_readonly, :readonly?
    refute_predicate attr_readonly, :readnone?
    refute_predicate attr_readonly, :writeonly?

    mem_readonly = attr_memory(21)
    assert_predicate mem_readonly, :readonly?
    refute_predicate mem_readonly, :readnone?
    refute_predicate mem_readonly, :writeonly?
  end

  def test_writeonly
    refute_predicate attr_writeonly, :readonly?
    refute_predicate attr_writeonly, :readnone?
    assert_predicate attr_writeonly, :writeonly?

    mem_writeonly = attr_memory(42)
    refute_predicate mem_writeonly, :readonly?
    refute_predicate mem_writeonly, :readnone?
    assert_predicate mem_writeonly, :writeonly?
  end

  private

  def attr_readnone
    LLVM::Attribute.enum(:readnone)
  end

  def attr_readonly
    LLVM::Attribute.enum(:readonly)
  end

  def attr_writeonly
    LLVM::Attribute.enum(:writeonly)
  end

  def attr_memory(bits)
    LLVM::Attribute.enum(:memory, bits)
  end

  def attr_memnone
    attr_memory(0)
  end
end
