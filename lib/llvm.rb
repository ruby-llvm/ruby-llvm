require 'rubygems'
require 'ffi'

module LLVM
  require 'llvm/support'

  # @private
  module C
    extend ::FFI::Library
    ffi_lib ['LLVM-3.2']
  end
end
