module LLVM  
  class Type
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def size
      Int64.from_ptr(C.LLVMSizeOf(self))
    end
    
    def align
      Int64.from_ptr(C.LLVMAlignOf(self))
    end
    
    def self.from_ptr(ptr)
      ptr.null? ? nil : new(ptr)
    end
    
    def self.array(ty, element_count)
      from_ptr(C.LLVMArrayType(LLVM::Type(ty), element_count))
    end
    
    def self.pointer(ty, address_space = 0)
      from_ptr(C.LLVMPointerType(LLVM::Type(ty), address_space))
    end
    
    def self.vector(ty, element_count)
      from_ptr(C.LLVMVectorType(LLVM::Type(ty), element_count))
    end
    
    def self.function(arg_types, result_type)
      arg_types.map! { |ty| LLVM::Type(ty) }
      arg_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * arg_types.size)
      arg_types_ptr.write_array_of_pointer(arg_types)
      from_ptr(C.LLVMFunctionType(LLVM::Type(result_type), arg_types_ptr, arg_types.size, 0))
    end
    
    def self.struct(elt_types, is_packed)
      elt_types.map! { |ty| LLVM::Type(ty) }
      elt_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * elt_types.size)
      elt_types_ptr.write_array_of_pointer(elt_types)
      from_ptr(C.LLVMStructType(elt_types_ptr, elt_types.size, is_packed ? 1 : 0))
    end
  end
  
  def LLVM.Type(ty)
    case ty
      when LLVM::Type then ty
      else ty.type
    end
  end
  
  def LLVM.Pointer(ty)
    LLVM::Type.pointer(ty)
  end
  
  def LLVM.Struct(*elt_types)
    LLVM::Type.struct(elt_types, false)
  end
end
