# frozen_string_literal: true

require "test_helper"

class IntegerTestCase < Minitest::Test
  def test_const_zext
    assert i = LLVM::Int8.from_i(-1)
    assert_equal 'i8 -1', i.to_s
    assert_equal :integer, i.type.kind
    assert_equal 8, i.type.width
    assert zext = i.zext(LLVM::Int64)
    assert_equal 'i64 255', zext.to_s
    assert_equal :integer, zext.type.kind
    assert_equal 64, zext.type.width
  end

  def test_const_sext
    assert i = LLVM::Int8.from_i(-1)
    assert_equal 'i8 -1', i.to_s
    assert_equal :integer, i.type.kind
    assert_equal 8, i.type.width
    assert sext = i.sext(LLVM::Int64)
    assert_equal 'i64 -1', sext.to_s
    assert_equal :integer, sext.type.kind
    assert_equal 64, sext.type.width
  end

  def test_const_int
    assert i = LLVM::Int64.from_i(-1)
    assert_equal "i64 -1", i.to_s
    assert_equal :integer, i.type.kind
    assert_equal 64, i.type.width
    assert_predicate i, :constant?
  end

  def test_const_int_bitcast
    assert_equal "double 0.000000e+00", LLVM::Int64.from_i(0).bitcast_to(LLVM::Double).to_s
    assert_equal "double 4.940660e-324", LLVM::Int64.from_i(1).bitcast_to(LLVM::Double).to_s
    assert_equal "double 0xFFFFFFFFFFFFFFFF", LLVM::Int64.from_i(-1).bitcast_to(LLVM::Double).to_s
  end

  def test_const_int_to_f
    assert_equal "double 0.000000e+00", LLVM::Int64.from_i(0).to_f(LLVM::Double).to_s
    assert_equal "double 1.000000e+00", LLVM::Int64.from_i(1).to_f(LLVM::Double).to_s
    assert_equal "double -1.000000e+00", LLVM::Int64.from_i(-1).to_f(LLVM::Double).to_s

    assert_equal "float 0.000000e+00", LLVM::Int64.from_i(0).to_f(LLVM::Float).to_s
    assert_equal "float 1.000000e+00", LLVM::Int64.from_i(1).to_f(LLVM::Float).to_s
    assert_equal "float -1.000000e+00", LLVM::Int64.from_i(-1).to_f(LLVM::Float).to_s

    assert_equal "double 0x43E0000000000000", LLVM::Int64.from_i((2**63) - 1).to_f(LLVM::Double).to_s
    assert_equal "double 0x43E0000000000000", LLVM::Int64.from_i((2**63) - 512).to_f(LLVM::Double).to_s
    assert_equal "double 0x43DFFFFFFFFFFFFF", LLVM::Int64.from_i((2**63) - 513).to_f(LLVM::Double).to_s
  end

  def test_const_double_null
    assert_equal "i64 0", LLVM::Constant.null(LLVM::Int64).to_s
  end

  def test_const_trunc
    assert i = LLVM::Int64.from_i(-1)
    assert_equal "i64 -1", i.to_s
    assert_equal "i8 -1", i.trunc(LLVM::Int8).to_s

    assert i = LLVM::Int64.from_i(128)
    assert_equal "i64 128", i.to_s
    assert_equal "i8 poison", i.trunc(LLVM::Int8).to_s

    assert i = LLVM::Int64.from_i(129)
    assert_equal "i64 129", i.to_s
    assert_equal "i8 poison", i.trunc(LLVM::Int8).to_s

    assert i = LLVM::Int64.from_i(-129)
    assert_equal "i64 -129", i.to_s
    assert_equal "i8 poison", i.trunc(LLVM::Int8).to_s
  end

  def test_const_add
    assert_equal "i64 3", (LLVM::Int64.from_i(2) + LLVM::Int64.from_i(1)).to_s
    assert_equal "i8 -128", LLVM::Int8.from_i(127).add(LLVM::Int8.from_i(1)).to_s
  end

  def test_const_nsw_add
    assert_equal "i64 3", LLVM::Int64.from_i(2).nsw_add(LLVM::Int64.from_i(1)).to_s
    assert_equal "i8 -128", LLVM::Int8.from_i(127).nsw_add(LLVM::Int8.from_i(1)).to_s
  end

  def test_const_nuw_add
    assert_equal "i64 3", LLVM::Int64.from_i(2).nuw_add(LLVM::Int64.from_i(1)).to_s
    assert_equal "i8 -128", LLVM::Int8.from_i(127).nuw_add(LLVM::Int8.from_i(1)).to_s
  end

  def test_const_sub
    assert_equal "i64 1", (LLVM::Int64.from_i(2) - LLVM::Int64.from_i(1)).to_s
  end

  def test_const_nsw_sub
    assert_equal "i64 1", LLVM::Int64.from_i(2).nsw_sub(LLVM::Int64.from_i(1)).to_s
  end

  def test_const_nuw_sub
    assert_equal "i64 1", LLVM::Int64.from_i(2).nuw_sub(LLVM::Int64.from_i(1)).to_s
  end

  def test_const_mul
    assert_equal "i64 2", (LLVM::Int64.from_i(2) * LLVM::Int64.from_i(1)).to_s
  end

  def test_const_nuw_mul
    assert_equal "i64 2", LLVM::Int64.from_i(2).nuw_mul(LLVM::Int64.from_i(1)).to_s
  end

  def test_const_nsw_mul
    assert_equal "i64 2", LLVM::Int64.from_i(2).nsw_mul(LLVM::Int64.from_i(1)).to_s
  end

  def test_const_sdiv
    assert_equal "i64 2", (LLVM::Int64.from_i(2) / LLVM::Int64.from_i(1)).to_s
  end

  def test_const_udiv
    assert_equal "i64 2", LLVM::Int64.from_i(2).udiv(LLVM::Int64.from_i(1)).to_s
  end

  NEG_TEST_NUMS = [-1, 0, 1, 127, -127].freeze

  def test_const_neg
    NEG_TEST_NUMS.each do |n|
      assert_equal LLVM::Int64.from_i(-n), -LLVM::Int64.from_i(n)
    end
  end

  def test_const_nsw_neg
    NEG_TEST_NUMS.each do |n|
      assert_equal LLVM::Int64.from_i(-n), LLVM::Int64.from_i(n).nsw_neg
    end
  end

  # This is likely not the expected behavior
  def test_const_neg_and_nsw_neg_overflow
    assert_equal LLVM::Int8.from_i(-128), LLVM::Int8.from_i(-128).nsw_neg
    assert_equal LLVM::Int8.from_i(-128), LLVM::Int8.from_i(-128).neg
    assert_equal LLVM::Int8.from_i(-128).to_s, LLVM::Int8.from_i(-128).nsw_neg.to_s
    assert_equal LLVM::Int8.from_i(-128).to_s, LLVM::Int8.from_i(-128).neg.to_s

    assert_predicate LLVM::Int8.from_i(128), :poison?
    assert_predicate LLVM::Int8.from_i(-129), :poison?
  end

  def test_const_rem
    assert_equal LLVM::Int8.from_i(1), LLVM::Int8.from_i(4).rem(LLVM::Int8.from_i(3))
  end

  def test_const_urem
    assert_equal LLVM::Int8.from_i(1), LLVM::Int8.from_i(4).urem(LLVM::Int8.from_i(3))
  end

  # boolean negation
  def test_const_not
    assert_equal LLVM::Int8.from_i(-1), ~LLVM::Int8.from_i(0)
    assert_equal LLVM::TRUE, ~LLVM::FALSE
    assert_equal LLVM::FALSE, ~LLVM::TRUE
  end

  def test_const_and
    assert_equal LLVM::Int8.from_i(0), LLVM::Int8.from_i(2) & LLVM::Int8.from_i(1)
  end

  def test_const_or
    assert_equal LLVM::Int8.from_i(3), LLVM::Int8.from_i(2) | LLVM::Int8.from_i(1)
  end

  def test_const_xor
    assert_equal LLVM::Int8.from_i(3), LLVM::Int8.from_i(2) ^ LLVM::Int8.from_i(1)
    assert_equal LLVM::Int8.from_i(-127), LLVM::Int8.from_i(-127) ^ LLVM::Int8.from_i(0)
    assert_equal LLVM::Int8.from_i(-127), LLVM::Int8.from_i(0) ^ LLVM::Int8.from_i(-127)
    assert_equal LLVM::Int8.from_i(91), LLVM::Int8.from_i(32) ^ LLVM::Int8.from_i(123)
  end

  def test_icmp
    assert_raises(LLVM::DeprecationError) do
      LLVM::Int8.from_i(2).icmp(:eq, LLVM::Int8.from_i(1))
    end
  end

  def test_shl
    assert_equal "i8 4", (LLVM::Int8.from_i(2) << LLVM::Int8.from_i(1)).to_s
  end

  def test_lshr
    assert_equal "i8 1", (LLVM::Int8.from_i(2) >> LLVM::Int8.from_i(1)).to_s
    assert_equal "i8 127", (LLVM::Int8.from_i(-2) >> LLVM::Int8.from_i(1)).to_s
  end

  def test_ashr
    assert_equal "i8 1", LLVM::Int8.from_i(2).ashr(LLVM::Int8.from_i(1)).to_s
    assert_equal "i8 -1", LLVM::Int8.from_i(-2).ashr(LLVM::Int8.from_i(1)).to_s
  end

  # TODO: this is not correct
  def test_const_all_ones
    assert_equal LLVM::Int8.from_i(-1), LLVM::Int8.all_ones
    assert_equal LLVM::Int8.from_i(-1).to_s, LLVM::Int8.all_ones.to_s
  end
end
