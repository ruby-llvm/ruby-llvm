# frozen_string_literal: true
# typed: strict

require 'llvm'
require 'llvm/core_ffi'
require 'llvm/core_ffi_v2'
require 'llvm/support'

module LLVM
  # Yields a pointer suitable for storing an LLVM output message.
  # If the message pointer is non-NULL (an error has happened), converts
  # the result to a string and returns it. Otherwise, returns +nil+.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [String, nil]
  #: { (FFI::MemoryPointer) -> Integer } -> String?
  def self.with_message_output(&)
    message = nil #: String?

    FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |str|
      result = yield str

      msg_ptr = str.read_pointer

      if result != 0
        raise "Error is signalled, but msg_ptr is null" if msg_ptr.null?

        message = msg_ptr.read_string
        C.dispose_message msg_ptr
      end
    end

    message
  end

  # Same as #with_message_output, but raises a RuntimeError with the
  # resulting message.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [nil]
  #: { (FFI::MemoryPointer) -> Integer } -> String?
  def self.with_error_output(&blk)
    error = with_message_output(&blk)

    raise error unless error.nil?
  end

  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/pass_builder'
  require 'llvm/core/bitcode'
  require 'llvm/core/attribute'
end
