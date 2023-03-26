# frozen_string_literal: true

require 'llvm'
require 'llvm/core_ffi'
require 'llvm/support'

module LLVM
  # @private
  module C
    attach_function :dispose_message, :LLVMDisposeMessage, [:pointer], :void

    # typedef unsigned LLVMAttributeIndex;
    typedef(:uint, :llvmattributeindex)

    # void LLVMAddAttributeAtIndex
    # (LLVMValueRef F, LLVMAttributeIndex Idx, LLVMAttributeRef A);
    attach_function :add_attribute_at_index, :LLVMAddAttributeAtIndex, [:pointer, :llvmattributeindex, :pointer], :void

    # void LLVMRemoveEnumAttributeAtIndex
    # (LLVMValueRef F, LLVMAttributeIndex Idx, unsigned KindID);
    attach_function :remove_enum_attribute_at_index, :LLVMRemoveEnumAttributeAtIndex, [:pointer, :llvmattributeindex, :uint], :void

    # LLVMAttributeRef LLVMCreateEnumAttribute
    # (LLVMContextRef C, unsigned KindID, uint64_t Val);
    attach_function :create_enum_attribute, :LLVMCreateEnumAttribute, [:pointer, :uint, :uint64], :pointer

    # unsigned LLVMGetEnumAttributeKindForName
    # (const char *Name, size_t SLen);
    attach_function :get_enum_attribute_kind_for_name, :LLVMGetEnumAttributeKindForName, [:pointer, :size_t], :uint

    # unsigned LLVMGetAttributeCountAtIndex
    # (LLVMValueRef F, LLVMAttributeIndex Idx);
    attach_function :get_attribute_count_at_index, :LLVMGetAttributeCountAtIndex, [:pointer, :llvmattributeindex], :uint

    # void LLVMGetAttributesAtIndex
    # (LLVMValueRef F, LLVMAttributeIndex Idx, LLVMAttributeRef *Attrs);
    attach_function :get_attributes_at_index, :LLVMGetAttributesAtIndex, [:pointer, :llvmattributeindex, :pointer], :void

    # unsigned LLVMGetEnumAttributeKind
    # (LLVMAttributeRef A);
    attach_function :get_enum_attribute_kind, :LLVMGetEnumAttributeKind, [:pointer], :uint

    # uint64_t LLVMGetEnumAttributeValue
    # (LLVMAttributeRef A);
    attach_function :get_enum_attribute_value, :LLVMGetEnumAttributeKind, [:pointer], :uint64

    # const char *LLVMGetStringAttributeKind
    # (LLVMAttributeRef A, unsigned *Length);
    attach_function :get_string_attribute_kind, :LLVMGetStringAttributeKind, [:pointer, :pointer], :pointer

    # const char *LLVMGetStringAttributeValue
    # (LLVMAttributeRef A, unsigned *Length);
    attach_function :get_string_attribute_value, :LLVMGetStringAttributeValue, [:pointer, :pointer], :pointer

    # LLVMValueRef LLVMBuildLoad2(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name);
    attach_function :build_load2, :LLVMBuildLoad2, [:pointer, :pointer, :pointer, :string], :pointer

    # LLVMValueRef LLVMBuildGEP2(LLVMBuilderRef B, LLVMTypeRef Ty,
    #                            LLVMValueRef Pointer, LLVMValueRef *Indices,
    #                            unsigned NumIndices, const char *Name);
    attach_function :build_gep2, :LLVMBuildGEP2, [:pointer, :pointer, :pointer, :pointer, :uint, :string], :pointer

    # LLVMValueRef LLVMBuildInBoundsGEP2(LLVMBuilderRef B, LLVMTypeRef Ty,
    #                                    LLVMValueRef Pointer, LLVMValueRef *Indices,
    #                                    unsigned NumIndices, const char *Name);
    attach_function :build_inbounds_gep2, :LLVMBuildInBoundsGEP2, [:pointer, :pointer, :pointer, :pointer, :uint, :string], :pointer

    # LLVMValueRef LLVMBuildStructGEP2(LLVMBuilderRef B, LLVMTypeRef Ty,
    #                                  LLVMValueRef Pointer, unsigned Idx,
    #                                  const char *Name);
    attach_function :build_struct_gep2, :LLVMBuildStructGEP2, [:pointer, :pointer, :pointer, :uint, :string], :pointer

    # LLVMValueRef LLVMBuildCall2(LLVMBuilderRef, LLVMTypeRef, LLVMValueRef Fn,
    #                             LLVMValueRef *Args, unsigned NumArgs,
    #                             const char *Name);
    attach_function :build_call2, :LLVMBuildCall2, [:pointer, :pointer, :pointer, :pointer, :uint, :string], :pointer

    # LLVMValueRef LLVMBuildInvoke2(LLVMBuilderRef, LLVMTypeRef Ty, LLVMValueRef Fn,
    #                               LLVMValueRef *Args, unsigned NumArgs,
    #                               LLVMBasicBlockRef Then, LLVMBasicBlockRef Catch,
    #                               const char *Name);
    attach_function :build_invoke2, :LLVMBuildInvoke2, [:pointer, :pointer, :pointer, :pointer, :uint, :pointer, :pointer, :string], :pointer

    # LLVMTypeRef LLVMGlobalGetValueType(LLVMValueRef Global);
    attach_function :global_get_value_type, :LLVMGlobalGetValueType, [:pointer], :pointer

    # LLVMTypeRef LLVMGetGEPSourceElementType(LLVMValueRef GEP);
    attach_function :get_gep_source_element_type, :LLVMGetGEPSourceElementType, [:pointer], :pointer

    # (Not documented)
    #
    # @method x86amx_type()
    # @return [FFI::Pointer(TypeRef)]
    # @scope class
    attach_function :x86amx_type, :LLVMX86AMXType, [], :pointer

    # LLVMTypeRef LLVMGetAllocatedType(LLVMValueRef Alloca);
    attach_function :get_allocated_type, :LLVMGetAllocatedType, [:pointer], :pointer

    # LLVMTypeRef LLVMGlobalGetValueType(LLVMValueRef Global);
    attach_function :get_value_type, :LLVMGlobalGetValueType, [:pointer], :pointer

    # LLVMValueRef LLVMGetAggregateElement(LLVMValueRef C, unsigned Idx);
    attach_function :get_aggregate_element, :LLVMGetAggregateElement, [:pointer, :int], :pointer

    attach_function :get_type_by_name2, :LLVMGetTypeByName2, [:pointer, :string], :pointer

    # Determine whether a structure is packed.
    #
    # @see llvm::StructType::isPacked()
    #
    # @method is_packed_struct(struct_ty)
    # @param [FFI::Pointer(TypeRef)] struct_ty
    # @return [Bool]
    # @scope class
    attach_function :is_packed_struct, :LLVMIsPackedStruct, [:pointer], :bool

    # Determine whether a structure is opaque.
    #
    # @see llvm::StructType::isOpaque()
    #
    # @method is_opaque_struct(struct_ty)
    # @param [FFI::Pointer(TypeRef)] struct_ty
    # @return [Bool]
    # @scope class
    attach_function :is_opaque_struct, :LLVMIsOpaqueStruct, [:pointer], :bool

    # Determine whether a structure is literal.
    #
    # @see llvm::StructType::isLiteral()
    #
    # @method is_literal_struct(struct_ty)
    # @param [FFI::Pointer(TypeRef)] struct_ty
    # @return [Bool]
    # @scope class
    attach_function :is_literal_struct, :LLVMIsLiteralStruct, [:pointer], :bool

    # /**
    #  * Read LLVM IR from a memory buffer and convert it into an in-memory Module
    #  * object. Returns 0 on success.
    #  * Optionally returns a human-readable description of any errors that
    #  * occurred during parsing IR. OutMessage must be disposed with
    #  * LLVMDisposeMessage.
    #  *
    #  * @see llvm::ParseIR()
    #  */
    # LLVMBool LLVMParseIRInContext(LLVMContextRef ContextRef,
    #                               LLVMMemoryBufferRef MemBuf, LLVMModuleRef *OutM,
    #                               char **OutMessage);
    attach_function :parse_ir_in_context, :LLVMParseIRInContext, [:pointer, :pointer, :pointer, :pointer], :bool
  end

  # Yields a pointer suitable for storing an LLVM output message.
  # If the message pointer is non-NULL (an error has happened), converts
  # the result to a string and returns it. Otherwise, returns +nil+.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [String, nil]
  def self.with_message_output
    message = nil

    FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |str|
      result = yield str

      msg_ptr = str.read_pointer

      if result != 0
        raise "Error is signalled, but msg_ptr is null" if msg_ptr.null?

        message = msg_ptr.read_string
        C.dispose_message msg_ptr
      end
    end

    message
  end

  # Same as #with_message_output, but raises a RuntimeError with the
  # resulting message.
  #
  # @yield  [FFI::MemoryPointer]
  # @return [nil]
  def self.with_error_output(&block)
    error = with_message_output(&block)

    raise error unless error.nil?
  end

  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/core/bitcode'
end
