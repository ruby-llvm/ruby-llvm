require 'llvm/core_ffi'

module LLVM

  module Support
    # @private

    module C
      extend FFI::Library

      OpaqueValue = LLVM::C::OpaqueValue

      lib_name = FFI.map_library_name('RubyLLVMSupport-3.2')
      lib_path = File.expand_path('../../../ext/ruby-llvm-support/' + lib_name, __FILE__)

      ffi_lib [lib_path]

      attach_function :load_library_permanently, :LLVMLoadLibraryPermanently, [:string], :int

      attach_function :has_unnamed_addr, :LLVMHasUnnamedAddr, [OpaqueValue], :int
      attach_function :set_unnamed_addr, :LLVMSetUnnamedAddr, [OpaqueValue, :int], :void
    end
  end

  def load_library(libname)
    Support::C.load_library_permanently(libname)

    nil
  end

  module_function :load_library
end
