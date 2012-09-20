module LLVM
  module Support
    # @private
    module C
      extend FFI::Library
      support_lib = File.expand_path(
                      File.join(
                        File.dirname(__FILE__),
                        '../',
                        FFI.map_library_name('RubyLLVMSupport-3.1.0')))
      ffi_lib [support_lib]
      attach_function :load_library_permanently, :LLVMLoadLibraryPermanently, [:string], :int
    end
  end

  def load_library(libname)
    Support::C.load_library_permanently(libname)
    nil
  end

  module_function :load_library
end
