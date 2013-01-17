require 'llvm'
require 'llvm/core'
require 'llvm/target'
require 'llvm/analysis'
require 'llvm/execution_engine_ffi'

module LLVM
  class JITCompiler
    # Important: Call #dispose to free backend memory after use. Do not call #dispose on mod any more.
    def initialize(mod, opt_level = 3)
      FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |ptr|
        error   = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status  = C.create_jit_compiler_for_module(ptr, mod, opt_level, error)
        errorp  = error.read_pointer
        message = errorp.read_string unless errorp.null?

        if status.zero?
          @ptr = ptr.read_pointer
        else
          C.dispose_message(error)
          error.autorelease=false
          raise RuntimeError, "Error creating JIT compiler: #{message}"
        end
      end
    end

    def dispose
      return if @ptr.nil?
      C.dispose_execution_engine(@ptr)
      @ptr = nil
    end

    # @private
    def to_ptr
      @ptr
    end

    # Get the associated data layout.
    #
    # @return [TargetDataLayout]
    def data_layout
      TargetDataLayout.from_ptr(C.get_execution_engine_target_data(self))
    end

    # Execute the given LLVM::Function with the supplied args (as
    # GenericValues).
    # Important: Call #dispose on the returned GenericValue to
    # free backend memory after use.
    def run_function(fun, *args)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size) do |args_ptr|
        new_values = []
        args_ptr.write_array_of_pointer fun.params.zip(args).map { |p, a|
          if a.kind_of?(GenericValue)
            a
          else
            value = LLVM.make_generic_value(p.type, a)
            new_values << value
            value
          end
        }
        result = LLVM::GenericValue.from_ptr(
          C.run_function(self, fun, args.size, args_ptr))
        new_values.each(&:dispose)
        return result
      end
    end

    # Obtain an FFI::Pointer to a global within the current module.
    def pointer_to_global(global)
      C.get_pointer_to_global(self, global)
    end
  end

  class GenericValue
    # @private
    def to_ptr
      @ptr
    end

    # Casts an FFI::Pointer pointing to a GenericValue to an instance.
    def self.from_ptr(ptr)
      return if ptr.null?
      val = allocate
      val.instance_variable_set(:@ptr, ptr)
      val
    end

    def dispose
      return if @ptr.nil?
      C.dispose_generic_value(@ptr)
      @ptr = nil
    end

    # Creates a Generic Value from an integer. Type is the size of integer to
    # create (ex. Int32, Int8, etc.)
    def self.from_i(i, options = {})
      type   = options.fetch(:type, LLVM::Int)
      signed = options.fetch(:signed, true)
      from_ptr(C.create_generic_value_of_int(type, i, signed ? 1 : 0))
    end

    # Creates a Generic Value from a Float.
    def self.from_f(f)
      from_ptr(C.create_generic_value_of_float(LLVM::Float, f))
    end

    def self.from_d(val)
      from_ptr(C.create_generic_value_of_float(LLVM::Double, val))
    end

    # Creates a GenericValue from a Ruby boolean.
    def self.from_b(b)
      from_i(b ? 1 : 0, LLVM::Int1, false)
    end

    # Creates a GenericValue from an FFI::Pointer pointing to some arbitrary value.
    def self.from_value_ptr(ptr)
      from_ptr(LLVM::C.create_generic_value_of_pointer(ptr))
    end

    # Converts a GenericValue to a Ruby Integer.
    def to_i(signed = true)
      v = C.generic_value_to_int(self, signed ? 1 : 0)
      v -= 2**64 if signed and v >= 2**63
      v
    end

    # Converts a GenericValue to a Ruby Float.
    def to_f(type = LLVM::Float.type)
      C.generic_value_to_float(type, self)
    end

    # Converts a GenericValue to a Ruby boolean.
    def to_b
      to_i(false) != 0
    end

    def to_value_ptr
      C.generic_value_to_pointer(self)
    end
  end

  # @private
  def make_generic_value(ty, val)
    case ty.kind
    when :double  then GenericValue.from_d(val)
    when :float   then GenericValue.from_f(val)
    when :pointer then GenericValue.from_value_ptr(val)
    when :integer then GenericValue.from_i(val, :type => ty)
    else
      raise "Unsupported type #{ty.kind}."
    end
  end
  module_function :make_generic_value
end
