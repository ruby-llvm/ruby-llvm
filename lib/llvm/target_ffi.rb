# Generated by ffi_gen. Please do not change this file by hand.

require 'ffi'

module LLVM::C
  extend FFI::Library
  ffi_lib 'LLVM-3.3'
  
  def self.attach_function(name, *_)
    begin; super; rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end
  
  # (Not documented)
  # 
  # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:byte_ordering).</em>
  # 
  # === Options:
  # :big_endian ::
  #   
  # :little_endian ::
  #   
  # 
  # @method _enum_byte_ordering_
  # @return [Symbol]
  # @scope class
  enum :byte_ordering, [
    :big_endian, 0,
    :little_endian, 1
  ]
  
  # (Not documented)
  class OpaqueTargetData < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class OpaqueTargetLibraryInfotData < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  class StructLayout < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # @method initialize_all_target_infos()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_target_infos, :LLVMInitializeAllTargetInfos, [], :void
  
  # LLVMInitializeAllTargets - The main program should call this function if it
  #     wants to link in all available targets that LLVM is configured to
  #     support.
  # 
  # @method initialize_all_targets()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_targets, :LLVMInitializeAllTargets, [], :void
  
  # LLVMInitializeAllTargetMCs - The main program should call this function if
  #     it wants access to all available target MC that LLVM is configured to
  #     support.
  # 
  # @method initialize_all_target_m_cs()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_target_m_cs, :LLVMInitializeAllTargetMCs, [], :void
  
  # LLVMInitializeAllAsmPrinters - The main program should call this function if
  #     it wants all asm printers that LLVM is configured to support, to make them
  #     available via the TargetRegistry.
  # 
  # @method initialize_all_asm_printers()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_asm_printers, :LLVMInitializeAllAsmPrinters, [], :void
  
  # LLVMInitializeAllAsmParsers - The main program should call this function if
  #     it wants all asm parsers that LLVM is configured to support, to make them
  #     available via the TargetRegistry.
  # 
  # @method initialize_all_asm_parsers()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_asm_parsers, :LLVMInitializeAllAsmParsers, [], :void
  
  # LLVMInitializeAllDisassemblers - The main program should call this function
  #     if it wants all disassemblers that LLVM is configured to support, to make
  #     them available via the TargetRegistry.
  # 
  # @method initialize_all_disassemblers()
  # @return [nil] 
  # @scope class
  attach_function :initialize_all_disassemblers, :LLVMInitializeAllDisassemblers, [], :void
  
  # LLVMInitializeNativeTarget - The main program should call this function to
  #     initialize the native target corresponding to the host.  This is useful 
  #     for JIT applications to ensure that the target gets linked in correctly.
  # 
  # @method initialize_native_target()
  # @return [Integer] 
  # @scope class
  attach_function :initialize_native_target, :LLVMInitializeNativeTarget, [], :int
  
  # Creates target data from a target layout string.
  #     See the constructor llvm::DataLayout::DataLayout.
  # 
  # @method create_target_data(string_rep)
  # @param [String] string_rep 
  # @return [OpaqueTargetData] 
  # @scope class
  attach_function :create_target_data, :LLVMCreateTargetData, [:string], OpaqueTargetData
  
  # Adds target data information to a pass manager. This does not take ownership
  #     of the target data.
  #     See the method llvm::PassManagerBase::add.
  # 
  # @method add_target_data(opaque_target_data, pass_manager_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(PassManagerRef)] pass_manager_ref 
  # @return [nil] 
  # @scope class
  attach_function :add_target_data, :LLVMAddTargetData, [OpaqueTargetData, :pointer], :void
  
  # Adds target library information to a pass manager. This does not take
  #     ownership of the target library info.
  #     See the method llvm::PassManagerBase::add.
  # 
  # @method add_target_library_info(opaque_target_library_infot_data, pass_manager_ref)
  # @param [OpaqueTargetLibraryInfotData] opaque_target_library_infot_data 
  # @param [FFI::Pointer(PassManagerRef)] pass_manager_ref 
  # @return [nil] 
  # @scope class
  attach_function :add_target_library_info, :LLVMAddTargetLibraryInfo, [OpaqueTargetLibraryInfotData, :pointer], :void
  
  # Converts target data to a target layout string. The string must be disposed
  #     with LLVMDisposeMessage.
  #     See the constructor llvm::DataLayout::DataLayout.
  # 
  # @method copy_string_rep_of_target_data(opaque_target_data)
  # @param [OpaqueTargetData] opaque_target_data 
  # @return [String] 
  # @scope class
  attach_function :copy_string_rep_of_target_data, :LLVMCopyStringRepOfTargetData, [OpaqueTargetData], :string
  
  # Returns the byte order of a target, either LLVMBigEndian or
  #     LLVMLittleEndian.
  #     See the method llvm::DataLayout::isLittleEndian.
  # 
  # @method byte_order(opaque_target_data)
  # @param [OpaqueTargetData] opaque_target_data 
  # @return [Symbol from _enum_byte_ordering_] 
  # @scope class
  attach_function :byte_order, :LLVMByteOrder, [OpaqueTargetData], :byte_ordering
  
  # Returns the pointer size in bytes for a target.
  #     See the method llvm::DataLayout::getPointerSize.
  # 
  # @method pointer_size(opaque_target_data)
  # @param [OpaqueTargetData] opaque_target_data 
  # @return [Integer] 
  # @scope class
  attach_function :pointer_size, :LLVMPointerSize, [OpaqueTargetData], :uint
  
  # Returns the pointer size in bytes for a target for a specified
  #     address space.
  #     See the method llvm::DataLayout::getPointerSize.
  # 
  # @method pointer_size_for_as(opaque_target_data, as)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [Integer] as 
  # @return [Integer] 
  # @scope class
  attach_function :pointer_size_for_as, :LLVMPointerSizeForAS, [OpaqueTargetData, :uint], :uint
  
  # Returns the integer type that is the same size as a pointer on a target.
  #     See the method llvm::DataLayout::getIntPtrType.
  # 
  # @method int_ptr_type(opaque_target_data)
  # @param [OpaqueTargetData] opaque_target_data 
  # @return [FFI::Pointer(TypeRef)] 
  # @scope class
  attach_function :int_ptr_type, :LLVMIntPtrType, [OpaqueTargetData], :pointer
  
  # Returns the integer type that is the same size as a pointer on a target.
  #     This version allows the address space to be specified.
  #     See the method llvm::DataLayout::getIntPtrType.
  # 
  # @method int_ptr_type_for_as(opaque_target_data, as)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [Integer] as 
  # @return [FFI::Pointer(TypeRef)] 
  # @scope class
  attach_function :int_ptr_type_for_as, :LLVMIntPtrTypeForAS, [OpaqueTargetData, :uint], :pointer
  
  # Computes the size of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeSizeInBits.
  # 
  # @method size_of_type_in_bits(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :size_of_type_in_bits, :LLVMSizeOfTypeInBits, [OpaqueTargetData, :pointer], :ulong_long
  
  # Computes the storage size of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeStoreSize.
  # 
  # @method store_size_of_type(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :store_size_of_type, :LLVMStoreSizeOfType, [OpaqueTargetData, :pointer], :ulong_long
  
  # Computes the ABI size of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeAllocSize.
  # 
  # @method abi_size_of_type(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :abi_size_of_type, :LLVMABISizeOfType, [OpaqueTargetData, :pointer], :ulong_long
  
  # Computes the ABI alignment of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeABISize.
  # 
  # @method abi_alignment_of_type(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :abi_alignment_of_type, :LLVMABIAlignmentOfType, [OpaqueTargetData, :pointer], :uint
  
  # Computes the call frame alignment of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeABISize.
  # 
  # @method call_frame_alignment_of_type(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :call_frame_alignment_of_type, :LLVMCallFrameAlignmentOfType, [OpaqueTargetData, :pointer], :uint
  
  # Computes the preferred alignment of a type in bytes for a target.
  #     See the method llvm::DataLayout::getTypeABISize.
  # 
  # @method preferred_alignment_of_type(opaque_target_data, type_ref)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] type_ref 
  # @return [Integer] 
  # @scope class
  attach_function :preferred_alignment_of_type, :LLVMPreferredAlignmentOfType, [OpaqueTargetData, :pointer], :uint
  
  # Computes the preferred alignment of a global variable in bytes for a target.
  #     See the method llvm::DataLayout::getPreferredAlignment.
  # 
  # @method preferred_alignment_of_global(opaque_target_data, global_var)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(ValueRef)] global_var 
  # @return [Integer] 
  # @scope class
  attach_function :preferred_alignment_of_global, :LLVMPreferredAlignmentOfGlobal, [OpaqueTargetData, :pointer], :uint
  
  # Computes the structure element that contains the byte offset for a target.
  #     See the method llvm::StructLayout::getElementContainingOffset.
  # 
  # @method element_at_offset(opaque_target_data, struct_ty, offset)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] struct_ty 
  # @param [Integer] offset 
  # @return [Integer] 
  # @scope class
  attach_function :element_at_offset, :LLVMElementAtOffset, [OpaqueTargetData, :pointer, :ulong_long], :uint
  
  # Computes the byte offset of the indexed struct element for a target.
  #     See the method llvm::StructLayout::getElementContainingOffset.
  # 
  # @method offset_of_element(opaque_target_data, struct_ty, element)
  # @param [OpaqueTargetData] opaque_target_data 
  # @param [FFI::Pointer(TypeRef)] struct_ty 
  # @param [Integer] element 
  # @return [Integer] 
  # @scope class
  attach_function :offset_of_element, :LLVMOffsetOfElement, [OpaqueTargetData, :pointer, :uint], :ulong_long
  
  # Deallocates a TargetData.
  #     See the destructor llvm::DataLayout::~DataLayout.
  # 
  # @method dispose_target_data(opaque_target_data)
  # @param [OpaqueTargetData] opaque_target_data 
  # @return [nil] 
  # @scope class
  attach_function :dispose_target_data, :LLVMDisposeTargetData, [OpaqueTargetData], :void
  
  # (Not documented)
  class OpaqueTargetMachine < FFI::Struct
    layout :dummy, :char
  end
  
  # (Not documented)
  module TargetWrappers
    def has_jit()
      LLVM::C.target_has_jit(self)
    end
    
    def has_target_machine()
      LLVM::C.target_has_target_machine(self)
    end
    
    def has_asm_backend()
      LLVM::C.target_has_asm_backend(self)
    end
  end
  
  class Target < FFI::Struct
    include TargetWrappers
    layout :dummy, :char
  end
  
  # (Not documented)
  # 
  # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:code_gen_opt_level).</em>
  # 
  # === Options:
  # :none ::
  #   
  # :less ::
  #   
  # :default ::
  #   
  # :aggressive ::
  #   
  # 
  # @method _enum_code_gen_opt_level_
  # @return [Symbol]
  # @scope class
  enum :code_gen_opt_level, [
    :none, 0,
    :less, 1,
    :default, 2,
    :aggressive, 3
  ]
  
  # (Not documented)
  # 
  # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:reloc_mode).</em>
  # 
  # === Options:
  # :default ::
  #   
  # :static ::
  #   
  # :pic ::
  #   
  # :dynamic_no_pic ::
  #   
  # 
  # @method _enum_reloc_mode_
  # @return [Symbol]
  # @scope class
  enum :reloc_mode, [
    :default, 0,
    :static, 1,
    :pic, 2,
    :dynamic_no_pic, 3
  ]
  
  # (Not documented)
  # 
  # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:code_model).</em>
  # 
  # === Options:
  # :default ::
  #   
  # :jit_default ::
  #   
  # :small ::
  #   
  # :kernel ::
  #   
  # :medium ::
  #   
  # :large ::
  #   
  # 
  # @method _enum_code_model_
  # @return [Symbol]
  # @scope class
  enum :code_model, [
    :default, 0,
    :jit_default, 1,
    :small, 2,
    :kernel, 3,
    :medium, 4,
    :large, 5
  ]
  
  # (Not documented)
  # 
  # <em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:code_gen_file_type).</em>
  # 
  # === Options:
  # :assembly ::
  #   
  # :object ::
  #   
  # 
  # @method _enum_code_gen_file_type_
  # @return [Symbol]
  # @scope class
  enum :code_gen_file_type, [
    :assembly, 0,
    :object, 1
  ]
  
  # Returns the first llvm::Target in the registered targets list.
  # 
  # @method get_first_target()
  # @return [Target] 
  # @scope class
  attach_function :get_first_target, :LLVMGetFirstTarget, [], Target
  
  # Returns the next llvm::Target given a previous one (or null if there's none)
  # 
  # @method get_next_target(t)
  # @param [Target] t 
  # @return [Target] 
  # @scope class
  attach_function :get_next_target, :LLVMGetNextTarget, [Target], Target
  
  # Returns the name of a target. See llvm::Target::getName
  # 
  # @method get_target_name(t)
  # @param [Target] t 
  # @return [String] 
  # @scope class
  attach_function :get_target_name, :LLVMGetTargetName, [Target], :string
  
  # Returns the description  of a target. See llvm::Target::getDescription
  # 
  # @method get_target_description(t)
  # @param [Target] t 
  # @return [String] 
  # @scope class
  attach_function :get_target_description, :LLVMGetTargetDescription, [Target], :string
  
  # Returns if the target has a JIT
  # 
  # @method target_has_jit(t)
  # @param [Target] t 
  # @return [Integer] 
  # @scope class
  attach_function :target_has_jit, :LLVMTargetHasJIT, [Target], :int
  
  # Returns if the target has a TargetMachine associated
  # 
  # @method target_has_target_machine(t)
  # @param [Target] t 
  # @return [Integer] 
  # @scope class
  attach_function :target_has_target_machine, :LLVMTargetHasTargetMachine, [Target], :int
  
  # Returns if the target as an ASM backend (required for emitting output)
  # 
  # @method target_has_asm_backend(t)
  # @param [Target] t 
  # @return [Integer] 
  # @scope class
  attach_function :target_has_asm_backend, :LLVMTargetHasAsmBackend, [Target], :int
  
  # Creates a new llvm::TargetMachine. See llvm::Target::createTargetMachine
  # 
  # @method create_target_machine(t, triple, cpu, features, level, reloc, code_model)
  # @param [Target] t 
  # @param [String] triple 
  # @param [String] cpu 
  # @param [String] features 
  # @param [Symbol from _enum_code_gen_opt_level_] level 
  # @param [Symbol from _enum_reloc_mode_] reloc 
  # @param [Symbol from _enum_code_model_] code_model 
  # @return [OpaqueTargetMachine] 
  # @scope class
  attach_function :create_target_machine, :LLVMCreateTargetMachine, [Target, :string, :string, :string, :code_gen_opt_level, :reloc_mode, :code_model], OpaqueTargetMachine
  
  # Dispose the LLVMTargetMachineRef instance generated by
  #   LLVMCreateTargetMachine.
  # 
  # @method dispose_target_machine(t)
  # @param [OpaqueTargetMachine] t 
  # @return [nil] 
  # @scope class
  attach_function :dispose_target_machine, :LLVMDisposeTargetMachine, [OpaqueTargetMachine], :void
  
  # Returns the Target used in a TargetMachine
  # 
  # @method get_target_machine_target(t)
  # @param [OpaqueTargetMachine] t 
  # @return [Target] 
  # @scope class
  attach_function :get_target_machine_target, :LLVMGetTargetMachineTarget, [OpaqueTargetMachine], Target
  
  # Returns the triple used creating this target machine. See
  #   llvm::TargetMachine::getTriple. The result needs to be disposed with
  #   LLVMDisposeMessage.
  # 
  # @method get_target_machine_triple(t)
  # @param [OpaqueTargetMachine] t 
  # @return [String] 
  # @scope class
  attach_function :get_target_machine_triple, :LLVMGetTargetMachineTriple, [OpaqueTargetMachine], :string
  
  # Returns the cpu used creating this target machine. See
  #   llvm::TargetMachine::getCPU. The result needs to be disposed with
  #   LLVMDisposeMessage.
  # 
  # @method get_target_machine_cpu(t)
  # @param [OpaqueTargetMachine] t 
  # @return [String] 
  # @scope class
  attach_function :get_target_machine_cpu, :LLVMGetTargetMachineCPU, [OpaqueTargetMachine], :string
  
  # Returns the feature string used creating this target machine. See
  #   llvm::TargetMachine::getFeatureString. The result needs to be disposed with
  #   LLVMDisposeMessage.
  # 
  # @method get_target_machine_feature_string(t)
  # @param [OpaqueTargetMachine] t 
  # @return [String] 
  # @scope class
  attach_function :get_target_machine_feature_string, :LLVMGetTargetMachineFeatureString, [OpaqueTargetMachine], :string
  
  # Returns the llvm::DataLayout used for this llvm:TargetMachine.
  # 
  # @method get_target_machine_data(t)
  # @param [OpaqueTargetMachine] t 
  # @return [OpaqueTargetData] 
  # @scope class
  attach_function :get_target_machine_data, :LLVMGetTargetMachineData, [OpaqueTargetMachine], OpaqueTargetData
  
  # Emits an asm or object file for the given module to the filename. This
  #   wraps several c++ only classes (among them a file stream). Returns any
  #   error in ErrorMessage. Use LLVMDisposeMessage to dispose the message.
  # 
  # @method target_machine_emit_to_file(t, m, filename, codegen, error_message)
  # @param [OpaqueTargetMachine] t 
  # @param [FFI::Pointer(ModuleRef)] m 
  # @param [String] filename 
  # @param [Symbol from _enum_code_gen_file_type_] codegen 
  # @param [FFI::Pointer(**CharS)] error_message 
  # @return [Integer] 
  # @scope class
  attach_function :target_machine_emit_to_file, :LLVMTargetMachineEmitToFile, [OpaqueTargetMachine, :pointer, :string, :code_gen_file_type, :pointer], :int
  
  # Compile the LLVM IR stored in \p M and store the result in \p OutMemBuf.
  # 
  # @method target_machine_emit_to_memory_buffer(t, m, codegen, error_message, out_mem_buf)
  # @param [OpaqueTargetMachine] t 
  # @param [FFI::Pointer(ModuleRef)] m 
  # @param [Symbol from _enum_code_gen_file_type_] codegen 
  # @param [FFI::Pointer(**CharS)] error_message 
  # @param [FFI::Pointer(*MemoryBufferRef)] out_mem_buf 
  # @return [Integer] 
  # @scope class
  attach_function :target_machine_emit_to_memory_buffer, :LLVMTargetMachineEmitToMemoryBuffer, [OpaqueTargetMachine, :pointer, :code_gen_file_type, :pointer, :pointer], :int
  
end
