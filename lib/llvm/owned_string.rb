# frozen_string_literal: true
# typed: true

require 'ffi'

module LLVM
  # Intended for LLVM functions that return a caller owned string which requires
  # freeing with `dispose_message` i.e. those declared `char *` rather than `const
  # char *`. Reads the buffer into a Ruby String and releases it with LLVMDisposeMessage.
  #
  # This prevents memory leaks at the expense of a string copy and free following return
  module OwnedString
    extend FFI::DataConverter

    native_type FFI::Type::POINTER

    #: (FFI::Pointer, untyped) -> String?
    def self.from_native(ptr, _ctx)
      return if ptr.null?

      begin
        ptr.read_string
      ensure
        LLVM::C.dispose_message(ptr)
      end
    end
  end

  # As OwnedString, but for LLVMGetErrorMessage, which the LLVM headers require
  # be freed with LLVMDisposeErrorMessage rather than LLVMDisposeMessage. The
  # two are not interchangeable, so this cannot share OwnedString.
  module OwnedErrorString
    extend FFI::DataConverter

    native_type FFI::Type::POINTER

    #: (FFI::Pointer, untyped) -> String?
    def self.from_native(ptr, _ctx)
      return if ptr.null?

      begin
        ptr.read_string
      ensure
        LLVM::C.dispose_error_message(ptr)
      end
    end
  end
end
