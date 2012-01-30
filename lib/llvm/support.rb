module LLVM
  module Support
    # @private
    module C
      extend FFI::Library
      support_lib = File.expand_path(
                      File.join(
                        File.dirname(__FILE__),
                        '../',
                        FFI.map_library_name('RubyLLVMSupport-3.0.0')))
      ffi_lib [support_lib]
      attach_function :LLVMLoadLibraryPermanently, [:string], :int
    end
  end

  def load_library(libname)
    Support::C.LLVMLoadLibraryPermanently(libname)
    nil
  end

  module_function :load_library
end
