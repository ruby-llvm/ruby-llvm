# frozen_string_literal: true

require 'llvm/core'

module LLVM
  # wrapper around LLVMOrcLLJITRef
  class LLJit

    # create lljit
    # does not automatically dispose of lljit
    # if lljit was disposed, that would dispose of builder
    def initialize
      builder = C.create_lljit_builder
      FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |ptr|
        error = C.create_lljit(ptr, builder)
        if error.null?
          @ptr = ptr.read_pointer
        else
          message = C.get_error_message(error)
          raise message
        end
      end
    end

    def triple_string
      C.get_triple_string(ptr)
    end

    def data_layout
      C.get_data_layout_str(ptr)
    end

    def global_prefix
      gp = C.get_global_prefix(ptr)
      gp.zero? ? "" : gp.chr
    end

    private

    attr_reader :ptr

    # currently returners pointer
    def main_jit_dylib
      C.main_jit_dylib(ptr)
    end

    module C
      extend FFI::Library
      ffi_lib_flags(:lazy, :global)
      ffi_lib ["libLLVM-17.so.1", "libLLVM.so.17", "LLVM-17"]

      attach_function :create_lljit_builder, :LLVMOrcCreateLLJITBuilder, [], :pointer
      attach_function :dispose_lljit_builder, :LLVMOrcDisposeLLJITBuilder, [:pointer], :void

      # LLVMErrorRef LLVMOrcCreateLLJIT(LLVMOrcLLJITRef *Result, LLVMOrcLLJITBuilderRef Builder);
      attach_function :create_lljit, :LLVMOrcCreateLLJIT, [:pointer, :pointer], :pointer

      # LLVMErrorRef LLVMOrcDisposeLLJIT(LLVMOrcLLJITRef J);
      attach_function :dispose_lljit, :LLVMOrcDisposeLLJIT, [:pointer], :pointer

      # const char *LLVMOrcLLJITGetTripleString(LLVMOrcLLJITRef J);
      attach_function :get_triple_string, :LLVMOrcLLJITGetTripleString, [:pointer], :string

      # const char *LLVMOrcLLJITGetDataLayoutStr(LLVMOrcLLJITRef J);
      attach_function :get_data_layout_str, :LLVMOrcLLJITGetDataLayoutStr, [:pointer], :string

      # char LLVMOrcLLJITGetGlobalPrefix(LLVMOrcLLJITRef J);
      attach_function :get_global_prefix, :LLVMOrcLLJITGetGlobalPrefix, [:pointer], :char

      # LLVMOrcJITDylibRef LLVMOrcLLJITGetMainJITDylib(LLVMOrcLLJITRef J);
      attach_function :get_main_jit_dylib, :LLVMOrcLLJITGetMainJITDylib, [:pointer], :pointer

      # LLVMOrcResourceTrackerRef
      # LLVMOrcJITDylibCreateResourceTracker(LLVMOrcJITDylibRef JD);
      attach_function :dylib_create_resource_tracker, :LLVMOrcJITDylibCreateResourceTracker,
                      [:pointer], :pointer

      # LLVMOrcThreadSafeContextRef LLVMOrcCreateNewThreadSafeContext(void);
      attach_function :create_new_thread_safe_context, :LLVMOrcCreateNewThreadSafeContext,
                      [], :pointer

      # LLVMOrcThreadSafeModuleRef
      # LLVMOrcCreateNewThreadSafeModule(LLVMModuleRef M,
      #                                                LLVMOrcThreadSafeContextRef TSCtx);
      attach_function :create_new_thread_safe_module, :LLVMOrcCreateNewThreadSafeContext,
                      [:pointer, :pointer], :pointer

      # LLVMErrorRef LLVMOrcLLJITAddLLVMIRModule(LLVMOrcLLJITRef J,
      #                                                          LLVMOrcJITDylibRef JD,
      #   LLVMOrcThreadSafeModuleRef TSM);
      attach_function :add_llvm_ir_module, :LLVMOrcLLJITAddLLVMIRModule,
                      [:pointer, :pointer, :pointer], :pointer

      # LLVMErrorRef LLVMOrcLLJITAddLLVMIRModuleWithRT(LLVMOrcLLJITRef J,
      #                                                                LLVMOrcResourceTrackerRef JD,
      #   LLVMOrcThreadSafeModuleRef TSM);
      attach_function :add_llvm_ir_module_with_rt, :LLVMOrcLLJITAddLLVMIRModuleWithRT,
                      [:pointer, :pointer, :pointer], :pointer

      # TODO: extract and combine with PassBuilder
      attach_function(:get_error_message, :LLVMGetErrorMessage, [:pointer], :string)

      attach_function(:dispose_error_message, :LLVMDisposeErrorMessage, [:string], :void)
    end
  end
end
