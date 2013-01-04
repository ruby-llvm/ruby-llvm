module LLVM

  module Support
    # @private
    module C
      extend FFI::Library

      class OpaqueValue < FFI::Struct
        layout :dummy, :char
      end

      support_lib = File.expand_path(
                      File.join(
                        File.dirname(__FILE__),
                        '../',
                        FFI.map_library_name('RubyLLVMSupport-3.1.0')))
      ffi_lib [support_lib]
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
