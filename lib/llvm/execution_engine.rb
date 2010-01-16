require 'llvm'
require 'llvm/core'
require 'llvm/target'
require 'llvm/analysis'

module LLVM
  module C
    ffi_lib 'LLVMExecutionEngine'
    
    # Generic values
    attach_function :LLVMCreateGenericValueOfInt, [:pointer, :ulong_long, :int], :pointer
    attach_function :LLVMCreateGenericValueOfPointer, [:pointer], :pointer
    attach_function :LLVMCreateGenericValueOfFloat, [:pointer, :double], :pointer
    
    attach_function :LLVMGenericValueIntWidth, [:pointer], :uint
    
    attach_function :LLVMGenericValueToInt, [:pointer, :int], :ulong_long
    attach_function :LLVMGenericValueToPointer, [:pointer], :pointer
    attach_function :LLVMGenericValueToFloat, [:pointer, :pointer], :double
    attach_function :LLVMDisposeGenericValue, [:pointer], :void
    
    # Execution engines
    attach_function :LLVMCreateExecutionEngine, [:pointer, :pointer, :pointer], :int
    attach_function :LLVMCreateInterpreter, [:pointer, :pointer, :pointer], :int
    attach_function :LLVMCreateJITCompiler, [:pointer, :pointer, :uint, :pointer], :int
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
    
    ffi_lib 'LLVMipa'
    ffi_lib 'LLVMTransformUtils'
    ffi_lib 'LLVMScalarOpts'
    ffi_lib 'LLVMCodeGen'
    ffi_lib 'LLVMAsmPrinter'
    ffi_lib 'LLVMSelectionDAG'
    ffi_lib 'LLVMJIT'
    ffi_lib 'LLVMInterpreter'
    ffi_lib 'LLVMMC'
    ffi_lib 'LLVMTransformUtils'
    
    ffi_lib 'LLVMX86Info'
    attach_function :LLVMInitializeX86TargetInfo, [], :void
    
    ffi_lib 'LLVMX86CodeGen'
    attach_function :LLVMInitializeX86Target, [], :void
  end
  
  def LLVM.init_x86
    LLVM::C.LLVMInitializeX86Target
    LLVM::C.LLVMInitializeX86TargetInfo
  end
  
  class ExecutionEngine
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.create_jit_compiler(provider, opt_level = 3)
      FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |ptr|
        error   = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status  = C.LLVMCreateJITCompiler(ptr, provider, opt_level, error)
        errorp  = error.read_pointer
        message = errorp.read_string unless errorp.null?
        
        if status.zero?
          return new(ptr.read_pointer)
        else
          C.LLVMDisposeMessage(error)
          raise RuntimeError, "Error creating JIT compiler: #{message}"
        end
      end
    end
    
    def run_function(fun, *args)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size) do |args_ptr|
        args_ptr.write_array_of_pointer(args.map { |arg| LLVM.GenericValue(arg).to_ptr })
        return LLVM::GenericValue.from_ptr(
          C.LLVMRunFunction(self, fun, args.size, args_ptr))
      end
    end
    
    def pointer_to_global(global)
      C.LLVMGetPointerToGlobal(self, global)
    end
  end
  
  class GenericValue
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.from_i(i, width = NATIVE_INT_SIZE, signed = false)
      type = LLVM.const_get("Int#{width}").type
      new(C.LLVMCreateGenericValueOfInt(type, i, signed ? 1 : 0))
    end
    
    def self.from_f(f)
      type = LLVM::Float.type
      new(C.LLVMCreateGenericValueOfFloat(type, f))
    end
    
    def self.from_ptr(ptr)
      new(ptr)
    end
    
    def to_i
      C.LLVMGenericValueToInt(self, 0)
    end
    
    def to_f
      C.LLVMGenericValueToFloat(LLVM::Float.type, self)
    end
  end
  
  def GenericValue(val)
    case val
      when GenericValue then val
      when Integer then GenericValue.from_i(val)
      when Float then GenericValue.from_f(val)
    end
  end
  module_function :GenericValue
end
