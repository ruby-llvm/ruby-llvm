require 'rubygems'
require 'ffi'

require 'llvm/support'

module LLVM
  # @private
  module C
    extend ::FFI::Library
    ffi_lib ['LLVM-3.1']
  end
end
