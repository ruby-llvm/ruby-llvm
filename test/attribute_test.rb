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
      assert_equal "#{attr_name}(0)", attr.inspect
      assert_equal LLVM::Attribute.new(attr_name), attr
    end
  end

  def test_function_readnone
    attr = LLVM::Attribute.enum(:readnone)
    with_function [], LLVM.Void do |fun|
      fun.add_attribute(attr)
      assert_equal(['readnone'], fun.attributes.map(&:to_s))
      assert_equal "; Function Attrs: readnone\ndeclare void @fun() #0\n", fun.to_s
    end
  end

  def test_function_memory
    vals = [
      "; Function Attrs: memory(none)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: read)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: write)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: readwrite)\ndeclare void @fun() #0\n",

      "; Function Attrs: memory(inaccessiblemem: read)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: read, inaccessiblemem: read)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: write, inaccessiblemem: read)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: readwrite, inaccessiblemem: read)\ndeclare void @fun() #0\n",

      "; Function Attrs: memory(inaccessiblemem: write)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: read, inaccessiblemem: write)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: write, inaccessiblemem: write)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: readwrite, inaccessiblemem: write)\ndeclare void @fun() #0\n",

      "; Function Attrs: memory(inaccessiblemem: readwrite)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: read, inaccessiblemem: readwrite)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: write, inaccessiblemem: readwrite)\ndeclare void @fun() #0\n",
      "; Function Attrs: memory(argmem: readwrite, inaccessiblemem: readwrite)\ndeclare void @fun() #0\n",

      "; Function Attrs: memory(read, argmem: none, inaccessiblemem: none)\ndeclare void @fun() #0\n",
    ]
    vals.each.with_index do |val, index|
      attr = LLVM::Attribute.enum(:memory, index)
      with_function [], LLVM.Void do |fun|
        fun.add_attribute(attr)
        assert_equal(val, fun.to_s)
      end
    end
  end

  def test_last_enum
    assert_equal 84, LLVM::Attribute.last_enum
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
    assert_equal '"unsafe-fp-math" = "false"', attr.inspect
  end

end
