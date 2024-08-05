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

    # LLVMAttributeRef LLVMCreateStringAttribute(LLVMContextRef C,
    #   const char *K, unsigned KLength,
    #   const char *V, unsigned VLength);
    attach_function :create_string_attribute, :LLVMCreateStringAttribute, [:pointer, :string, :uint, :string, :uint], :pointer

    # unsigned LLVMGetEnumAttributeKindForName
    # (const char *Name, size_t SLen);
    attach_function :get_enum_attribute_kind_for_name, :LLVMGetEnumAttributeKindForName, [:pointer, :size_t], :uint

    attach_function :get_last_enum_attribute_kind, :LLVMGetLastEnumAttributeKind, [], :uint

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
    attach_function :get_enum_attribute_value, :LLVMGetEnumAttributeValue, [:pointer], :uint64

    # const char *LLVMGetStringAttributeKind
    # (LLVMAttributeRef A, unsigned *Length);
    attach_function :get_string_attribute_kind, :LLVMGetStringAttributeKind, [:pointer, :pointer], :string

    # const char *LLVMGetStringAttributeValue
    # (LLVMAttributeRef A, unsigned *Length);
    attach_function :get_string_attribute_value, :LLVMGetStringAttributeValue, [:pointer, :pointer], :string

    attach_function :is_enum_attribute, :LLVMIsEnumAttribute, [:pointer], :bool
    attach_function :is_string_attribute, :LLVMIsStringAttribute, [:pointer], :bool
    attach_function :is_type_attribute, :LLVMIsTypeAttribute, [:pointer], :bool

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

    enum :value_kind, [
      :argument, 0,
      :basic_block, 1,
      :memory_use, 2,
      :memory_def, 3,
      :memory_phi, 4,
      :function, 5,
      :global_alias, 6,
      :global_ifunc, 7,
      :global_variable, 8,
      :block_address, 9,
      :const_expr, 10,
      :const_array, 11,
      :const_struct, 12,
      :const_vector, 13,
      :undef, 14,
      :const_aggregregate_zero, 15,
      :const_data_array, 16,
      :const_data_vector, 17,
      :const_int, 18,
      :const_fp, 19,
      :const_null, 20,
      :const_none, 21,
      :metadata, 22,
      :inline_asm, 23,
      :instruction, 24,
      :poison, 25,
    ]

    # /**
    #  * Obtain the enumerated type of a Value instance.
    #  *
    #  * @see llvm::Value::getValueID()
    #  */
    attach_function :get_value_kind, :LLVMGetValueKind, [:pointer], :value_kind

    attach_function :get_poison, :LLVMGetPoison, [:pointer], :pointer

    attach_function :const_int_get_sext_value, :LLVMConstIntGetSExtValue, [:pointer], :long_long

    attach_function :const_int_get_zext_value, :LLVMConstIntGetZExtValue, [:pointer], :ulong_long

    # (Not documented)
    #
    # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:atomic_rmw_bin_op).</em>
    #
    # === Options:
    # :xchg ::
    #
    # :add ::
    #   < Set the new value and return the one old
    # :sub ::
    #   < Add a value and return the old one
    # :and_ ::
    #   < Subtract a value and return the old one
    # :nand ::
    #   < And a value and return the old one
    # :or_ ::
    #   < Not-And a value and return the old one
    # :xor ::
    #   < OR a value and return the old one
    # :max ::
    #   < Xor a value and return the old one
    # :min ::
    #   < Sets the value if it's greater than the
    #                                original using a signed comparison and return
    #                                the old one
    # :u_max ::
    #   < Sets the value if it's Smaller than the
    #                                original using a signed comparison and return
    #                                the old one
    # :u_min ::
    #   < Sets the value if it's greater than the
    #                                original using an unsigned comparison and return
    #                                the old one
    #
    # @method _enum_atomic_rmw_bin_op_
    # @return [Symbol]
    # @scope class
    enum :atomic_rmw_bin_op, [
      :xchg,
      :add,
      :sub,
      :and,
      :nand,
      :or,
      :xor,
      :max,
      :min,
      :umax,
      :umin,
      :fadd,
      :fsub,
      :fmax,
      :fmin,
      :uincwrap,
      :udecwrap,
    ]

    # (Not documented)
    #
    # @method build_atomic_rmw(b, op, ptr, val, ordering, single_thread)
    # @param [FFI::Pointer(BuilderRef)] b
    # @param [Symbol from _enum_atomic_rmw_bin_op_] op
    # @param [FFI::Pointer(ValueRef)] ptr
    # @param [FFI::Pointer(ValueRef)] val
    # @param [Symbol from _enum_atomic_ordering_] ordering
    # @param [Integer] single_thread
    # @return [FFI::Pointer(ValueRef)]
    # @scope class
    attach_function :build_atomic_rmw, :LLVMBuildAtomicRMW, [:pointer, :atomic_rmw_bin_op, :pointer, :pointer, :atomic_ordering, :int], :pointer

    # Create a ConstantDataSequential and initialize it with a string.
    #
    # @see llvm::ConstantDataArray::getString()
    #
    # @method const_string_in_context(c, str, length, dont_null_terminate)
    # @param [FFI::Pointer(ContextRef)] c
    # @param [String] str
    # @param [Integer] length
    # @param [Integer] dont_null_terminate
    # @return [FFI::Pointer(ValueRef)]
    # @scope class
    attach_function :const_string_in_context2, :LLVMConstStringInContext2, [:pointer, :string, :size_t, :int], :pointer
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
  require 'llvm/transforms/pass_builder'
  require 'llvm/core/bitcode'
  require 'llvm/core/attribute'
end
