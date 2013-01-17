require 'llvm'
require 'llvm/core_ffi'
require 'llvm/support'

module LLVM
  # @private
  module C
    attach_function :dispose_message, :LLVMDisposeMessage, [:pointer], :void
  end

  # Yields a pointer suitable for storing an LLVM output message.
  # If the message pointer is non-NULL (an error has happened), converts
  # the result to a string and returns it. Otherwise, returns +nil+.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [String, nil]
  def self.with_message_output
    result = nil

    FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |str|
      yield str

      msg_ptr = str.read_pointer

      unless msg_ptr.null?
        result = msg_ptr.read_string
        C.dispose_message msg_ptr
      end
    end

    result
  end

  # Same as #with_message_output, but raises a RuntimeError with the
  # resulting message.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [nil]
  def self.with_error_output(&block)
    error = with_message_output(&block)

    raise RuntimeError, error unless error.nil?
  end

  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/core/bitcode'
end
