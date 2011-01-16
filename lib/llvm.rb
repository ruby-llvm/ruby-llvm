require 'ffi'

module LLVM
  module C
    extend ::FFI::Library

    # load required libraries
    begin
      ffi_lib ['LLVM-2.8', 'libLLVM-2.8']
    rescue LoadError
      ffi_lib ['LLVM-2.7', 'libLLVM-2.7']
    end
  end
  
  NATIVE_INT_SIZE = case FFI::Platform::ARCH
    when "x86_64" then 64
    # PPC, other arches?
    else 32
  end
end
