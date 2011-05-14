module LLVM  
  class Type
    # @private
    def to_ptr
      @ptr
    end
    
    # LLVM's represents types uniquely, and supports pointer equality. 
    def ==(type)
      case type
      when LLVM::Type
        @ptr == type.to_ptr
      else
        false
      end
    end

    # Checks if the type is equal to other.
    def eql?(other)
      other.instance_of?(self.class) && self == other
    end

    # Returns a symbol representation of the types kind (ex. :pointer, :vector, :array.)
    def kind
      C.LLVMGetTypeKind(self)
    end

    # Returns the size of the type.
    def size
      LLVM::Int64.from_ptr(C.LLVMSizeOf(self))
    end
    
    def align
      LLVM::Int64.from_ptr(C.LLVMAlignOf(self))
    end

    # Returns the type of this types elements (works only for Pointer, Vector, and Array types.)
    def element_type
      case self.kind
      when :pointer, :vector, :array
        Type.from_ptr(C.LLVMGetElementType(self))
      end
    end

    # Returns a null pointer ConstantExpr of this type.
    def null_pointer
      ConstantExpr.from_ptr(C.LLVMConstPointerNull(self))
    end

    # Returns a null ConstantExpr of this type.
    def null
      ConstantExpr.from_ptr(C.LLVMConstNull(self))
    end

    # Creates a pointer type with this type and the given address space.
    def pointer(address_space = 0)
      Type.pointer(self, address_space)
    end
    
    # @private
    def self.from_ptr(ptr)
      return if ptr.null?
      ty = allocate
      ty.instance_variable_set(:@ptr, ptr)
      ty
    end
    
    # Creates an array type of Type with the given size.
    def self.array(ty, sz = 0)
      from_ptr(C.LLVMArrayType(LLVM::Type(ty), sz))
    end
    
    # Creates the pointer type of Type with the given address space.
    def self.pointer(ty, address_space = 0)
      from_ptr(C.LLVMPointerType(LLVM::Type(ty), address_space))
    end
    
    # Creates a vector type of Type with the given element count.
    def self.vector(ty, element_count)
      from_ptr(C.LLVMVectorType(LLVM::Type(ty), element_count))
    end
    
    # Creates a function type. Takes an array of argument Types and the result Type. The only option is <tt>:varargs</tt>, 
    # which when set to true makes the function type take a variable number of args.
    def self.function(arg_types, result_type, options = {})
      arg_types.map! { |ty| LLVM::Type(ty) }
      arg_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * arg_types.size)
      arg_types_ptr.write_array_of_pointer(arg_types)
      FunctionType.from_ptr(C.LLVMFunctionType(LLVM::Type(result_type), arg_types_ptr, arg_types.size, options[:varargs] ? 1 : 0))
    end
    
    # Creates a struct type with the given array of element types.
    def self.struct(elt_types, is_packed)
      elt_types.map! { |ty| LLVM::Type(ty) }
      elt_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * elt_types.size)
      elt_types_ptr.write_array_of_pointer(elt_types)
      from_ptr(C.LLVMStructType(elt_types_ptr, elt_types.size, is_packed ? 1 : 0))
    end

    # Creates a void type.
    def self.void
      from_ptr(C.LLVMVoidType)
    end
    
    # Creates an opaque type.
    def self.opaque
      from_ptr(C.LLVMOpaqueType)
    end
    
    def self.rec
      h = opaque
      ty = yield h
      h.refine(ty)
      ty
    end
    
    def refine(ty)
      C.LLVMRefineType(self, ty)
    end
  end

  class IntType < Type
    def width
      C.LLVMGetIntTypeWidth(self)
    end
  end

  class FunctionType < Type
    def return_type
      LLVM::Type.from_ptr(C.LLVMGetReturnType(self))
    end
  end

  module_function
  
  # Creates a Type from the given object.
  def Type(ty)
    case ty
    when LLVM::Type then ty
    else ty.type
    end
  end
  
  # Shortcut to Type.array.
  def Array(ty, sz = 0)
    LLVM::Type.array(ty, sz)
  end
  
  # Shortcut to Type.pointer.
  def Pointer(ty)
    LLVM::Type.pointer(ty)
  end
  
  # Shortcut to Type.vector.
  def Vector(ty, sz)
    LLVM::Type.vector(ty, sz)
  end
  
  # Shortcut to Type.function.
  def Function(argtypes, rettype, options = {})
    LLVM::Type.function(argtypes, rettype, options)
  end
  
  # Shortcut to Type.struct.
  def Struct(*elt_types)
    LLVM::Type.struct(elt_types, false)
  end

  # Shortcut to Type.void.
  def Void
    LLVM::Type.void
  end
end
