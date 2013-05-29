require 'llvm/core_ffi'

module LLVM

  module Support
    # @private

    module C
      extend FFI::Library

      OpaqueValue  = LLVM::C::OpaqueValue
      OpaqueType   = LLVM::C::OpaqueType
      OpaqueModule = LLVM::C::OpaqueModule

      lib_name = FFI.map_library_name("RubyLLVMSupport-#{LLVM_VERSION}")
      lib_path = File.expand_path("../../ext/ruby-llvm-support/#{lib_name}", File.dirname(__FILE__))
      ffi_lib [lib_path]

      attach_function :load_library_permanently, :LLVMLoadLibraryPermanently, [:string], :int
      attach_function :has_unnamed_addr, :LLVMHasUnnamedAddr, [OpaqueValue], :int
      attach_function :set_unnamed_addr, :LLVMSetUnnamedAddr, [OpaqueValue, :int], :void
      attach_function :dump_type, :LLVMDumpType, [OpaqueType], :void
      attach_function :print_module, :LLVMPrintModuleToFD, [OpaqueModule, :int, :int, :int], :void

      attach_function :initialize_all_target_infos,
          :LLVMInitializeAllTargetInfos, [], :void
      attach_function :initialize_all_targets,
          :LLVMInitializeAllTargets, [], :void
      attach_function :initialize_all_target_mcs,
          :LLVMInitializeAllTargetMCs, [], :void
      attach_function :initialize_all_asm_printers,
          :LLVMInitializeAllAsmPrinters, [], :void

      attach_function :initialize_native_target,
          :LLVMInitializeNativeTarget, [], :void
      attach_function :initialize_native_target_asm_printer,
          :LLVMInitializeNativeTargetAsmPrinter, [], :void
    end
  end

  def load_library(libname)
    Support::C.load_library_permanently(libname)

    nil
  end

  module_function :load_library
end
