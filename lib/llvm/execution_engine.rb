require 'llvm'
require 'llvm/core'
require 'llvm/target'
require 'llvm/analysis'
require 'llvm/execution_engine_ffi'

module LLVM
  # @abstract Subclass and override {#create_execution_engine_for_module}.
  class ExecutionEngine
    # Create a JIT execution engine for module with the given options.
    #
    # @note Important: Call #dispose to free backend memory after use. Do not call #dispose on mod any more.
    #
    # @param [LLVM::Module] mod module
    # @param [Hash{Symbol => Object}] options options
    # @return [ExecutionEngine] JIT execution engine
    def initialize(mod, options)
      FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |ptr|
        error   = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status  = create_execution_engine_for_module(ptr, mod, error, options)
        errorp  = error.read_pointer
        message = errorp.read_string unless errorp.null?

        if status.zero?
          @ptr = ptr.read_pointer
        else
          C.dispose_message(error)
          error.autorelease = false
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

    # Get the associated target machine.
    #
    # @return [TargetMachine]
    def target_machine
      TargetMachine.from_ptr(C.get_execution_engine_target_machine(self))
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

    def function_address(name)
      C.get_function_address(self, name)
    end

    # Returns a ModuleCollection of all the Modules in the engine.
    # @return [ModuleCollection]
    def modules
      @modules ||= ModuleCollection.new(self)
    end

    # Returns a FunctionCollection of all the Functions in the engine.
    # @return [FunctionCollection]
    def functions
      @functions ||= FunctionCollection.new(self)
    end

    class ModuleCollection
      # @param [ExecutionEngine] engine
      def initialize(engine)
        @engine = engine
      end

      # @param [LLVM::Module] mod
      # @return [ModuleCollection]
      def add(mod)
        tap { C.add_module(@engine, mod) }
      end

      # @param [LLVM::Module] mod
      # @return [LLVM::Module] deleted module
      def delete(mod)
        error   = FFI::MemoryPointer.new(:pointer)
        out_mod = FFI::MemoryPointer.new(:pointer)

        status = C.remove_module(@engine, mod, out_mod, error)

        if status.zero?
          LLVM::Module.from_ptr(out_mod.read_pointer)
        else
          errorp  = error.read_pointer
          message = errorp.read_string unless errorp.null?

          C.dispose_message(error)
          error.autorelease = false

          raise "Error removing module: #{message}"
        end
      end

      alias_method :<<, :add
    end

    class FunctionCollection
      # @param [ExecutionEngine] engine
      def initialize(engine)
        @engine = engine
      end

      # @param [String, Symbol] name function name
      # @return [Function]
      def named(name)
        out_fun = FFI::MemoryPointer.new(:pointer)

        status = C.find_function(@engine, name.to_s, out_fun)
        return unless status.zero?

        Function.from_ptr(out_fun.read_pointer)
      end

      alias_method :[], :named
    end

    protected

    # Create a JIT execution engine for module with the given options.
    #
    # @param [FFI::Pointer(*ExecutionEngineRef)] out_ee execution engine
    # @param [LLVM::Module] mod module
    # @param [FFI::Pointer(**CharS)] out_error error message
    # @param [Hash{Symbol => Object}] options options. `:opt_level => 3` for example.
    # @return [Integer] 0 for success, non- zero to indicate an error
    def create_execution_engine_for_module(out_ee, mod, out_error, options)
      raise NotImplementedError, "override in subclass"
    end
  end

  class MCJITCompiler < ExecutionEngine
    # Create a MCJIT execution engine.
    #
    # @note You should call `LLVM.init_jit(true)` before creating an execution engine.
    # @todo Add :mcjmm option (MCJIT memory manager)
    #
    # @param [LLVM::Module] mod module
    # @param [Hash{Symbol => Object}] options options
    # @option options [Integer] :opt_level (2) Optimization level
    # @option options [Integer] :code_model (0) Code model types
    # @option options [Boolean] :no_frame_pointer_elim (false) Disable frame pointer elimination optimization
    # @option options [Boolean] :enable_fast_i_sel (false) Enables fast-path instruction selection
    # @return [ExecutionEngine] Execution engine
    def initialize(mod, options = {})
      options = {
        :opt_level             => 2, # LLVMCodeGenLevelDefault
        # code_model causes segfault with LLVMCodeModelDefault (0) so using
        # LLVMCodeModelJITDefault (1) instead
        :code_model            => 1,
        :no_frame_pointer_elim => false,
        :enable_fast_i_sel     => false,
        # TODO
        #:mcjmm                 => nil,
      }.merge(options)

      super
    end

    def convert_type(type)
      case type.kind
      when :integer
        if type.width <= 8
          :int8
        else
          "int#{type.width}".to_sym
        end
      else
        type.kind
      end
    end

    def run_function(fun, *args)
      args2 = fun.params.map {|e| convert_type(e.type)}
      ptr = FFI::Pointer.new(function_address(fun.name))
      raise "Couldn't find function" if ptr.null?

      return_type = convert_type(fun.function_type.return_type)
      f = FFI::Function.new(return_type, args2, ptr)
      ret1 = f.call(*args)
      ret2 = LLVM.make_generic_value(fun.function_type.return_type, ret1)
      return ret2
    end

    protected

    def create_execution_engine_for_module(out_ee, mod, out_error, options)
      mcopts = LLVM::C::MCJITCompilerOptions.new

      LLVM::C.initialize_mcjit_compiler_options(mcopts, mcopts.size)

      mcopts[:opt_level]             = options[:opt_level]
      mcopts[:code_model]            = options[:code_model]
      mcopts[:no_frame_pointer_elim] = options[:no_frame_pointer_elim] ? 1 : 0
      mcopts[:enable_fast_i_sel]     = options[:enable_fast_i_sel] ? 1 : 0

      C.create_mcjit_compiler_for_module(out_ee, mod, mcopts, mcopts.size, out_error)
    end
  end

  JITCompiler = MCJITCompiler

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
