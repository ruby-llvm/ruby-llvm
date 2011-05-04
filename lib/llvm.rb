require 'rubygems'
require 'ffi'

module LLVM
  # @private
  module C
    extend ::FFI::Library

    # load required libraries
    ffi_lib ['LLVM-2.9', 'libLLVM-2.9']
  end
end
