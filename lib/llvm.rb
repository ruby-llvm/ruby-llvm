require 'rubygems'
require 'ffi'

module LLVM
  # @private
  module C
    extend ::FFI::Library
    ffi_lib ['LLVM-3.1']
  end
end
