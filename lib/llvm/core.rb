require 'llvm'
require 'llvm/core_ffi'
require 'llvm/support'

module LLVM
  # @private
  module C
    attach_function :dispose_message, :LLVMDisposeMessage, [:pointer], :void
  end

  # Yields a pointer suitable for storing an LLVM output message.
  # If the block returns +1+ (an error has happened), converts the
  # result to a string and returns it. Otherwise, returns +nil+.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [String, nil]
  def self.with_message_output
    result = nil

    FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |str|
      status = yield str
      result = str.read_string if status == 1
      C.dispose_message str.read_pointer
    end

    result
  end

  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/core/bitcode'
end
