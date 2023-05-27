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
      attr = LLVM::Attribute.create_enum(attr_name)
      assert_equal attr_name, attr.kind.to_sym
      assert_instance_of LLVM::Attribute, attr
      assert_predicate attr, :enum?
      refute_predicate attr, :string?
      refute_predicate attr, :type?
      assert_equal "#{attr_name}(0)", attr.inspect
    end
  end

  def test_last_enum
    assert_equal 84, LLVM::Attribute.last_enum
  end

  def test_create_string
    k = "unsafe-fp-math"
    v = "false"
    attr = LLVM::Attribute.create_string(k, v)
    assert_instance_of LLVM::Attribute, attr
    assert_predicate attr, :string?
    refute_predicate attr, :enum?
    refute_predicate attr, :type?
    assert_equal v, attr.value
    assert_equal '"unsafe-fp-math" = "false"', attr.inspect
  end

end
