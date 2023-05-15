# frozen_string_literal: true

require "test_helper"

class AttributeTestCase < Minitest::Test

  ATTRIBUTE_KINDS = [
    [:readnone, 47],
    [:readonly, 48],
  ].freeze

  def test_create_enums
    ATTRIBUTE_KINDS.each do |pair|
      attr = LLVM::Attribute.create_enum(pair[0])
      assert_equal pair[1], attr.kind
      assert_instance_of LLVM::Attribute, attr
      assert_predicate attr, :enum?
      refute_predicate attr, :string?
      refute_predicate attr, :type?
    end
  end

  def test_last_enum
    assert_equal 85, LLVM::Attribute.last_enum
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
  end

  def test_create_type
    # k = "unsafe-fp-math"
    # v = "false"
    # attr = LLVM::Attribute.create_string(k, v)
    # assert_instance_of LLVM::Attribute, attr
    # assert_predicate attr, :type?
    # refute_predicate attr, :string?
    # refute_predicate attr, :enum?
    # assert_equal v, attr.value
  end

end
