# frozen_string_literal: true
# typed: true

require "test_helper"
require 'llvm/lljit'

class LLJitTest < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_create_lljit
    assert LLVM::LLJit.new
  end

  def test_lljit_strings_exist
    lljit = LLVM::LLJit.new
    refute_empty(lljit.triple_string)
    refute_empty(lljit.data_layout)
    assert(lljit.global_prefix)
  end

  def test_lljit_strings
    skip "This test is platform dependent"
    lljit = LLVM::LLJit.new
    assert_equal("x86_64-pc-linux-gnu", lljit.triple_string)
    assert_equal("e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", lljit.data_layout)
    assert_equal("", lljit.global_prefix)
  end
end
