# frozen_string_literal: true

require 'llvm'
require 'llvm/core'
require 'llvm/target_ffi'

module LLVM
  # A shorthand for {LLVM::Target.init_native}
  def self.init_jit(*args)
    LLVM::Target.init_native(*args)
  end

  # @deprecated Use LLVM.init_jit or LLVM::Target.init('X86').
  def self.init_x86
    warn "LLVM.init_x86 is deprecated. Use LLVM.init_jit or LLVM::Target.init('X86')."
    LLVM::Target.init('X86')
  end

  # You need to call {Target.init} for a target to be usable.
  class Target
    # Initializes target +target+; in particular, TargetInfo, Target and TargetMC.
    #
    # @param [String]      target      Target name in LLVM format, e.g. "X86", "ARM" or "PowerPC".
    # @param [true, false] asm_printer Initialize corresponding AsmPrinter.

    module TargetModule
      extend FFI::Library
      ffi_lib ["libLLVM-18.so.1", "libLLVM.so.18", "LLVM-18"]

      def self.safe_attach_function(*args)
        attach_function(*args)
      rescue FFI::NotFoundError => e
        warn(e)
      end
    end

    def self.init(target, asm_printer = false)
      target_module = TargetModule.dup
      target_module.module_eval do
        attach_function :"initialize_target_info_#{target}", :"LLVMInitialize#{target}TargetInfo", [], :void
        attach_function :"initialize_target_#{target}", :"LLVMInitialize#{target}Target", [], :void
        attach_function :"initialize_target_#{target}_mc", :"LLVMInitialize#{target}TargetMC", [], :void

        if asm_printer
          attach_function(:"initialize_#{target}_asm_printer", :"LLVMInitialize#{target}AsmPrinter", [], :void)
        end
        safe_attach_function :"initialize_#{target}_asm_parser", :"LLVMInitialize#{target}AsmParser", [], :void
        safe_attach_function :"initialize_#{target}_disassembler", :"LLVMInitialize#{target}Disassembler", [], :void
      end

      C.extend(target_module)

      begin
        %W(initialize_target_info_#{target}
           initialize_target_#{target}
           initialize_target_#{target}_mc).each do |init|
          C.send init
        end
      rescue FFI::NotFoundError
        raise ArgumentError, "LLVM target #{target} is not linked in. Try `llvm-config-#{LLVM_VERSION} --targets-built'."
      end

      begin
        C.send :"initialize_#{target}_asm_printer" if asm_printer
      rescue FFI::NotFoundError => e
        raise ArgumentError, "LLVM target #{target} does not implement an ASM routime: #{e.message}"
      end
    end

    # Initializes all available targets.
    #
    # @param [true, false] asm_printer Initialize corresponding AsmPrinters.
    def self.init_all(asm_printer = false)
      Support::C.initialize_all_target_infos
      Support::C.initialize_all_targets
      Support::C.initialize_all_target_mcs

      Support::C.initialize_all_asm_printers if asm_printer
    end

    # Initializes native target. Useful for JIT applications.
    #
    # @param [true, false] asm_printer Initialize corresponding AsmPrinter.
    #   True by default, as this is required for MCJIT to function.
    def self.init_native(asm_printer = true)
      Support::C.initialize_native_target

      Support::C.initialize_native_asm_printer if asm_printer
    end

    # Enumerate all initialized targets.
    #
    # @yield [Target]
    def self.each(&block)
      return to_enum(:each) if block.nil?

      target = C.get_first_target
      until target.null?
        yield from_ptr(target)

        target = C.get_next_target(target)
      end
    end

    # Fetch a target by its name.
    #
    # @return [Target]
    def self.by_name(name)
      each do |target|
        return target if target.name == name
      end
    end

    include PointerIdentity

    # @private
    def self.from_ptr(ptr)
      target = allocate
      target.instance_variable_set :@ptr, ptr
      target
    end

    # Returns the name of the target.
    #
    # @return [String]
    def name
      C.get_target_name(self)
    end

    # Returns the description of the target.
    #
    # @return [String]
    def description
      C.get_target_description(self)
    end

    # Returns if the target has a JIT.
    def jit?
      !C.target_has_jit(self).zero?
    end

    # Returns if the target has a TargetMachine associated.
    def target_machine?
      !C.target_has_target_machine(self).zero?
    end

    # Returns if the target has an ASM backend (required for emitting output).
    def asm_backend?
      !C.target_has_asm_backend(self).zero?
    end

    # Constructs a TargetMachine.
    #
    # @param  [String]        triple     Target triple
    # @param  [String]        cpu        Target CPU
    # @param  [String]        features   Target feature string
    # @param  [Symbol]        opt_level  :none, :less, :default, :aggressive
    # @param  [Symbol]        reloc      :default, :static, :pic, :dynamic_no_pic
    # @param  [Symbol]        code_model :default, :jit_default, :small, :kernel, :medium, :large
    # @return [TargetMachine]
    def create_machine(triple, cpu = "", features = "",
                       opt_level = :default, reloc = :default, code_model = :default)
      TargetMachine.from_ptr(C.create_target_machine(self,
            triple, cpu, features, opt_level, reloc, code_model))
    end
  end

  class TargetMachine
    include PointerIdentity

    # @private
    def self.from_ptr(ptr)
      target = allocate
      target.instance_variable_set :@ptr, ptr
      target
    end

    # Destroys this instance of TargetMachine.
    def dispose
      return if @ptr.nil?

      C.dispose_target_machine(self)
      @ptr = nil
    end

    # Returns the corresponding Target.
    #
    # @return [Target]
    def target
      Target.from_ptr(C.get_target_machine_target(self))
    end

    # Returns the triple used for creating this target machine.
    def triple
      C.get_target_machine_triple(self)
    end

    # Returns the CPU used for creating this target machine.
    def cpu
      C.get_target_machine_cpu(self)
    end

    # Returns the feature string used for creating this target machine.
    def features
      C.get_target_machine_feature_string(self)
    end

    # Emits an asm or object file for the given module.
    #
    # @param [Symbol] codegen :assembly, :object
    def emit(mod, filename, codegen = :assembly)
      LLVM.with_error_output do |err|
        C.target_machine_emit_to_file(self, mod, filename.to_s, codegen, err)
      end
    end
  end

  # @private
  module C
    # ffi_gen autodetects :string, which is too weak to be usable
    # with LLVMDisposeMessage
    attach_function :copy_string_rep_of_target_data, :LLVMCopyStringRepOfTargetData, [OpaqueTargetData], :pointer
  end

  class TargetDataLayout
    # Creates a target data layout from a string representation.
    #
    # @param [String] representation
    def initialize(representation)
      @ptr = C.create_target_data(representation.to_s)
    end

    # @private
    def self.from_ptr(ptr)
      target = allocate
      target.instance_variable_set :@ptr, ptr
      target
    end

    # @private
    def to_ptr
      @ptr
    end

    # Destroys this instance of TargetDataLayout.
    def dispose
      return if ptr.nil?

      C.dispose_target_data(self)
      @ptr = nil
    end

    # Returns string representation of target data layout.
    #
    # @return [String]
    def to_s
      string_ptr = C.copy_string_rep_of_target_data(self)
      string = string_ptr.read_string
      C.dispose_message(string_ptr)

      string
    end

    # Returns the byte order of a target, either :big_endian or :little_endian.
    def byte_order
      C.byte_order(self)
    end

    # Returns the pointer size in bytes for a target.
    #
    # @param [Integer] addr_space address space number
    def pointer_size(addr_space = 0)
      C.pointer_size_for_as(self, addr_space)
    end

    # Returns the integer type that is the same size as a pointer on a target.
    #
    # @param [Integer] addr_space address space number
    def int_ptr_type(addr_space = 0)
      Type.from_ptr(C.int_ptr_type_for_as(self, addr_space), :integer)
    end

    # Computes the size of a type in bits for a target.
    def bit_size_of(type)
      C.size_of_type_in_bits(self, type)
    end

    # Computes the storage size of a type in bytes for a target.
    def storage_size_of(type)
      C.store_size_of_type(self, type)
    end

    # Computes the ABI size of a type in bytes for a target.
    def abi_size_of(type)
      C.abi_size_of_type(self, type)
    end

    # Computes the ABI alignment of a type in bytes for a target.
    def abi_alignment_of(type)
      C.abi_alignment_of_type(self, type)
    end

    # Computes the call frame alignment of a type in bytes for a target.
    def call_frame_alignment_of(type)
      C.call_frame_alignment_of_type(self, type)
    end

    # Computes the preferred alignment of a type or a global variable in bytes
    # for a target.
    #
    # @param [LLVM::Type, LLVM::GlobalValue] entity
    def preferred_alignment_of(entity)
      case entity
      when LLVM::Type
        C.preferred_alignment_of_type(self, entity)
      when LLVM::GlobalValue
        C.preferred_alignment_of_global(self, entity)
      end
    end

    # Computes the structure element that contains the byte offset for a target.
    def element_at_offset(type, offset)
      C.element_at_offset(self, type, offset)
    end

    # Computes the byte offset of the indexed struct element for a target.
    def offset_of_element(type, element)
      C.offset_of_element(self, type, element)
    end
  end
end
