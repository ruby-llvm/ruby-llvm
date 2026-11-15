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

  def test_lljit_matches_ffi
    lljit = LLVM::LLJit.new
    layout = LLVM::TargetDataLayout.new(lljit.data_layout)

    assert_equal(FFI.type_size(:pointer), layout.pointer_size)
    little = FFI::Platform::BYTE_ORDER == FFI::Platform::LITTLE_ENDIAN
    assert_equal(little ? :little_endian : :big_endian, layout.byte_order)
    assert_equal(FFI::Platform.mac? ? "_" : "", lljit.global_prefix)
  end
end
