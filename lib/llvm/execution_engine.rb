require 'llvm'
require 'llvm/core'
require 'llvm/target'
require 'llvm/analysis'

module LLVM
  # @private
  module C
    # Generic values
    attach_function :LLVMCreateGenericValueOfInt, [:pointer, :long_long, :int], :pointer
    attach_function :LLVMCreateGenericValueOfPointer, [:pointer], :pointer
    attach_function :LLVMCreateGenericValueOfFloat, [:pointer, :double], :pointer

    attach_function :LLVMGenericValueIntWidth, [:pointer], :uint

    attach_function :LLVMGenericValueToInt, [:pointer, :int], :long_long
    attach_function :LLVMGenericValueToPointer, [:pointer], :pointer
    attach_function :LLVMGenericValueToFloat, [:pointer, :pointer], :double
    attach_function :LLVMDisposeGenericValue, [:pointer], :void

    # Execution engines
    attach_function :LLVMCreateExecutionEngineForModule, [:pointer, :pointer, :pointer], :int
    attach_function :LLVMCreateInterpreterForModule, [:pointer, :pointer, :pointer], :int
    attach_function :LLVMCreateJITCompilerForModule, [:pointer, :pointer, :uint, :pointer], :int
    attach_function :LLVMDisposeExecutionEngine, [:pointer], :void

    attach_function :LLVMRunStaticConstructors, [:pointer], :void
    attach_function :LLVMRunStaticDestructors, [:pointer], :void

    attach_function :LLVMRunFunctionAsMain, [:pointer, :pointer, :uint, :pointer, :pointer], :int
    attach_function :LLVMRunFunction, [:pointer, :pointer, :uint, :pointer], :pointer

    attach_function :LLVMFreeMachineCodeForFunction, [:pointer, :pointer], :void
    attach_function :LLVMAddModuleProvider, [:pointer, :pointer], :void
    attach_function :LLVMRemoveModuleProvider, [:pointer, :pointer, :pointer, :pointer], :int

    attach_function :LLVMFindFunction, [:pointer, :pointer, :pointer, :pointer], :int

    attach_function :LLVMGetExecutionEngineTargetData, [:pointer], :pointer

    attach_function :LLVMAddGlobalMapping, [:pointer, :pointer, :pointer], :void

    attach_function :LLVMGetPointerToGlobal, [:pointer, :pointer], :pointer

    attach_function :LLVMInitializeX86TargetInfo, [], :void

    attach_function :LLVMInitializeX86Target, [], :void
  end

  def LLVM.init_x86
    LLVM::C.LLVMInitializeX86Target
    LLVM::C.LLVMInitializeX86TargetInfo
  end

  class ExecutionEngine
    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end

    # @private
    def to_ptr
      @ptr
    end

    # Create a JIT compiler with an LLVM::Module.
    def self.create_jit_compiler(mod, opt_level = 3)
      FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |ptr|
        error   = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status  = C.LLVMCreateJITCompilerForModule(ptr, mod, opt_level, error)
        errorp  = error.read_pointer
        message = errorp.read_string unless errorp.null?

        if status.zero?
          return new(ptr.read_pointer)
        else
          C.LLVMDisposeMessage(error)
          error.autorelease=false
          raise RuntimeError, "Error creating JIT compiler: #{message}"
        end
      end
    end

    # Execute the given LLVM::Function with the supplied args (as
    # GenericValues).
    def run_function(fun, *args)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size) do |args_ptr|
        args_ptr.write_array_of_pointer(args.map { |arg| LLVM.GenericValue(arg).to_ptr })
        return LLVM::GenericValue.from_ptr(
          C.LLVMRunFunction(self, fun, args.size, args_ptr))
      end
    end

    # Obtain an FFI::Pointer to a global within the current module.
    def pointer_to_global(global)
      C.LLVMGetPointerToGlobal(self, global)
    end
  end

  class GenericValue
    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end

    # @private
    def to_ptr
      @ptr
    end

    # Creates a Generic Value from an integer. Type is the size of integer to
    # create (ex. Int32, Int8, etc.)
    def self.from_i(i, type = LLVM::Int, signed = true)
      new(C.LLVMCreateGenericValueOfInt(type, i, signed ? 1 : 0))
    end

    # Creates a Generic Value from a Float.
    def self.from_f(f)
      type = LLVM::Float.type
      new(C.LLVMCreateGenericValueOfFloat(type, f))
    end
    
    # Creates a GenericValue from a Ruby boolean.
    def self.from_b(b)
      from_i(b ? 1 : 0, LLVM::Int1, false)
    end

    # Creates a GenericValue from an FFI::Pointer.
    def self.from_ptr(ptr)
      new(ptr)
    end

    # Converts a GenericValue to a Ruby Integer.
    def to_i(signed = true)
      C.LLVMGenericValueToInt(self, signed ? 1 : 0)
    end

    # Converts a GenericValue to a Ruby Float.
    def to_f(type = LLVM::Float.type)
      C.LLVMGenericValueToFloat(type, self)
    end
    
    # Converts a GenericValue to a Ruby boolean.
    def to_b
      to_i(false) != 0
    end
  end

  # Creates a GenericValue from an object (GenericValue, Integer, Float, true,
  # false).
  def LLVM.GenericValue(val)
    case val
    when GenericValue then val
    when ::Integer then GenericValue.from_i(val)
    when ::Float then GenericValue.from_f(val)
    when ::TrueClass then GenericValue.from_b(true)
    when ::FalseClass then GenericValue.from_b(false)
    end
  end
end
