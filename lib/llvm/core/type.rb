# frozen_string_literal: true

module LLVM
  class Type
    include PointerIdentity

    # @private
    def self.from_ptr(ptr, kind = nil)
      return if ptr.null?
      kind ||= C.get_type_kind(ptr)
      ty = case kind
      when :integer
        IntType.allocate
      when :function
        FunctionType.allocate
      when :struct
        StructType.allocate
      else
        allocate
      end
      ty.instance_variable_set(:@ptr, ptr)
      ty.instance_variable_set(:@kind, kind)
      ty
    end

    # Returns a symbol representation of the types kind (ex. :pointer, :vector, :array.)
    def kind
      @kind
    end

    # Returns the size of the type.
    def size
      LLVM::Int64.from_ptr(C.size_of(self))
    end

    def align
      LLVM::Int64.from_ptr(C.align_of(self))
    end

    # Returns the type of this types elements (works only for Pointer, Vector, and Array types.)
    def element_type
      case kind
      when :vector, :array
        element_type = C.get_element_type(self)
        Type.from_ptr(element_type)
      when :pointer
        LLVM.Void
      else
        raise "element_type not supported for kind: #{kind}"
      end
    end

    # Returns a null pointer ConstantExpr of this type.
    def null_pointer
      ConstantExpr.from_ptr(C.const_pointer_null(self))
    end

    # Returns a null ConstantExpr of this type.
    def null
      ConstantExpr.from_ptr(C.const_null(self))
    end

    # Creates a pointer type with this type and the given address space.
    def pointer(address_space = 0)
      Type.pointer(self, address_space)
    end

    # Print the type's representation to stdout.
    def dump
      C.dump_type(self)
    end

    # Build string of LLVM type representation.
    def to_s
      C.print_type_to_string(self)
    end

    def aggregate?
      [:struct, :array].include?(kind)
    end

    def opaque_struct?
      C.is_opaque_struct(self)
    end

    def packed_struct?
      C.is_packed_struct(self)
    end

    def literal_struct?
      C.is_literal_struct(self)
    end

    # Creates an array type of Type with the given size.
    # arrays can be size >= 0, https://llvm.org/docs/LangRef.html#array-type
    def self.array(ty, sz = 0)
      sz = sz.to_i
      raise ArgumentError, "LLVM Array size must be >= 0" if sz.negative?

      from_ptr(C.array_type(LLVM::Type(ty), sz), :array)
    end

    # Creates the pointer type of Type with the given address space.
    def self.pointer(ty = nil, address_space = 0)
      if ty
        from_ptr(C.pointer_type(LLVM::Type(ty), address_space), :pointer)
      else
        ptr(address_space)
      end
    end

    # opaque pointer
    def self.ptr(address_space = 0)
      from_ptr(C.pointer_type(void, address_space), :pointer)
    end

    # Creates a vector type of Type with the given element count.
    # vectors can be size > 0, https://llvm.org/docs/LangRef.html#vector-type
    def self.vector(ty, element_count)
      element_count = element_count.to_i
      raise ArgumentError, "LLVM Vector size must be > 0" unless element_count.positive?

      from_ptr(C.vector_type(LLVM::Type(ty), element_count), :vector)
    end

    # Creates a function type. Takes an array of argument Types and the result Type. The only option is <tt>:varargs</tt>,
    # which when set to true makes the function type take a variable number of args.
    def self.function(arg_types, result_type, options = {})
      arg_types.map! { |ty| LLVM::Type(ty) }
      arg_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * arg_types.size)
      arg_types_ptr.write_array_of_pointer(arg_types)
      from_ptr(C.function_type(LLVM::Type(result_type), arg_types_ptr, arg_types.size, options[:varargs] ? 1 : 0), :function)
    end

    # Creates a struct type with the given array of element types.
    def self.struct(elt_types, is_packed, name = nil)
      elt_types.map! { |ty| LLVM::Type(ty) }
      elt_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * elt_types.size)
      elt_types_ptr.write_array_of_pointer(elt_types)
      if name
        struct = from_ptr(C.struct_create_named(Context.global, name), :struct)
        C.struct_set_body(struct, elt_types_ptr, elt_types.size, is_packed ? 1 : 0) unless elt_types.empty?
        struct
      else
        from_ptr(C.struct_type(elt_types_ptr, elt_types.size, is_packed ? 1 : 0), :struct)
      end
    end

    def self.opaque_struct(name)
      from_ptr(C.struct_create_named(Context.global, name.to_s), :struct)
    end

    def self.named(name)
      from_ptr(C.get_type_by_name2(Context.global, name.to_s), nil)
    end

    # Creates a void type.
    def self.void
      from_ptr(C.void_type, :void)
    end

    def self.label
      from_ptr(C.label_type, :label)
    end

    def self.x86_mmx
      from_ptr(C.x86mmx_type, :x86mmx)
    end

    def self.x86_amx
      from_ptr(C.x86amx_type, :x86amx)
    end
    # def self.opaque_pointer
    #  from_ptr(C.opaque_type, :pointer)
    # end

    def self.rec
      h = opaque
      ty = yield h
      h.refine(ty)
      ty
    end
  end

  class IntType < Type
    def width
      C.get_int_type_width(self)
    end
  end

  class FunctionType < Type
    def return_type
      Type.from_ptr(C.get_return_type(self))
    end

    def element_type
      self
    end

    def argument_types
      size = C.count_param_types(self)
      result = nil
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * size) do |types_ptr|
        C.get_param_types(self, types_ptr)
        result = types_ptr.read_array_of_pointer(size)
      end
      result.map { |p| Type.from_ptr(p, nil) }
    end

    def vararg?
      C.is_function_var_arg(self) != 0
    end
  end

  class StructType < Type
    # Returns the name of the struct.
    def name
      C.get_struct_name(self)
    end

    # Returns the element types of the struct.
    def element_types
      count = C.count_struct_element_types(self)
      elt_types = nil
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * count) do |types_ptr|
        C.get_struct_element_types(self, types_ptr)
        elt_types = types_ptr.read_array_of_pointer(count).map { |type_ptr| Type.from_ptr(type_ptr, nil) }
      end
      elt_types
    end

    # Sets the struct body.
    def element_types=(elt_types)
      elt_types.map! { |ty| LLVM::Type(ty) }
      elt_types_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * elt_types.size)
      elt_types_ptr.write_array_of_pointer(elt_types)
      C.struct_set_body(self, elt_types_ptr, elt_types.size, 0)
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
  def Pointer(ty = nil)
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
    name = if elt_types.last.is_a? String
      elt_types.pop
    else
      nil
    end
    LLVM::Type.struct(elt_types, false, name)
  end

  # Shortcut to Type.void.
  def Void
    LLVM::Type.void
  end

end
