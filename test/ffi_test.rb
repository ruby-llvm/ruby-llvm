# frozen_string_literal: true

require "test_helper"
require "llvm/core"

class FfiTest < Minitest::Test
  def test_ffi_not_found
    assert_raises(FFI::NotFoundError) do
      LLVM::C.attach_function :does_not_exit, :DoesNotExist, [], :void
    end
  end
end
