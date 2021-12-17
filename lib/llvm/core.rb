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
