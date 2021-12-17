# frozen_string_literal: true

require 'llvm/core_ffi'

module LLVM

  module Support
    # @private

    module C
      extend FFI::Library

      lib_name = FFI.map_library_name("RubyLLVMSupport-#{LLVM_VERSION}")
      lib_path = File.expand_path("../../ext/ruby-llvm-support/#{lib_name}", File.dirname(__FILE__))
      ffi_lib [lib_path]

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
      attach_function :initialize_native_asm_printer,
          :LLVMInitializeNativeAsmPrinter, [], :void
    end
  end

  def self.load_library(libname)
    if C.load_library_permanently(libname) != 0
      raise "LLVM::Support.load_library failed"
    end

    nil
  end
end
