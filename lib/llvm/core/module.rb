# frozen_string_literal: true
# typed: true

module LLVM
  class Module
    include PointerIdentity

    # @private
    #: (FFI::Pointer) -> LLVM::Module?
    def self.from_ptr(ptr)
      return if ptr.null?
      mod = allocate
      mod.instance_variable_set(:@ptr, ptr)
      mod
    end

    # Important: Call #dispose to free backend memory after use, but not when using JITCompiler with this module.
    def initialize(name)
      @ptr = C.module_create_with_name(name)
    end

    def dispose
      return if @ptr.nil?

      C.dispose_module(@ptr)
      @ptr = nil
    end

    #: -> LLVM::Module?
    def clone_module
      Module.from_ptr(C.clone_module(self))
    end

    #: -> String
    def inspect
      {
        triple: triple,
        globals: globals.count,
        functions: functions.count,
        lines: to_s.lines.size,
        valid: valid?,
      }.to_s
    end

    # Get module triple.
    #
    # @return [String]
    #: -> String
    def triple
      C.get_target(self)
    end

    # Set module triple.
    #
    # @param [String] triple
    #: (String) -> void
    def triple=(triple)
      C.set_target(self, triple.to_s)
    end

    # Get module data layout.
    #
    # @return [String]
    #: -> String
    def data_layout
      C.get_data_layout(self)
    end

    # Set module data layout.
    #
    # @param [String, TargetDataLayout] data_layout
    #: (String) -> void
    def data_layout=(data_layout)
      C.set_data_layout(self, data_layout.to_s)
    end

    # Returns a TypeCollection of all the Types in the module.
    #: -> TypeCollection
    def types
      @types ||= TypeCollection.new(self)
    end

    class TypeCollection
      def initialize(mod)
        @module = mod
      end

      # Returns the Type with the given name (symbol or string).
      #: (String | Symbol) -> Type
      def named(name)
        Type.from_ptr(C.get_type_by_name(@module, name.to_s))
      end

      alias_method :[], :named
    end

    # Returns an Enumerable of all the GlobalVariables in the module.
    #: -> GlobalCollection
    def globals
      @globals ||= GlobalCollection.new(self)
    end

    class GlobalCollection
      include Enumerable

      def initialize(mod)
        @module = mod
      end

      # Adds a GlobalVariable with the given type and name to the collection (symbol or string).
      #: (untyped, String | Symbol) ?{ (GlobalVariable) -> void } -> GlobalVariable
      def add(ty, name, &)
        GlobalVariable.from_ptr(C.add_global(@module, LLVM::Type(ty), name.to_s)).tap do |gvar|
          yield gvar if block_given?
        end
      end

      # Returns the GlobalVariable with the given name (symbol or string).
      #: (String | Symbol) -> GlobalVariable?
      def named(name)
        ptr = C.get_named_global(@module, name.to_s)
        GlobalVariable.from_ptr(ptr) unless ptr.null?
      end

      # Returns the first GlobalVariable in the collection.
      #: -> GlobalVariable?
      def first
        ptr = C.get_first_global(@module)
        GlobalVariable.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last GlobalVariable in the collection.
      #: -> GlobalVariable?
      def last
        ptr = C.get_last_global(@module)
        GlobalVariable.from_ptr(ptr) unless ptr.null?
      end

      # Returns the next GlobalVariable in the collection after global.
      #: (GlobalVariable) -> GlobalVariable?
      def next(global)
        ptr = C.get_next_global(global)
        GlobalVariable.from_ptr(ptr) unless ptr.null?
      end

      # Returns the previous GlobalVariable in the collection before global.
      #: (GlobalVariable) -> GlobalVariable?
      def previous(global)
        ptr = C.get_previous_global(global)
        GlobalVariable.from_ptr(ptr) unless ptr.null?
      end

      # Deletes the GlobalVariable from the collection.
      #: (GlobalVariable) -> void
      def delete(global)
        C.delete_global(global)
      end

      # Returns the GlobalVariable with a name equal to key (symbol or string) or at key (integer).
      #: (String | Symbol | Integer) -> GlobalVariable?
      def [](key)
        case key
        when String, Symbol then named(key)
        when Integer then
          i = 0
          g = first #: GlobalVariable?
          until i >= key || g.nil?
            g = self.next(g)
            i += 1
          end
          g
        end
      end

      # Iterates through each GlobalVariable in the collection.
      # @override
      #: { (GlobalVariable) -> void } -> void
      def each(&)
        g = first #: GlobalVariable?
        until g.nil?
          yield g
          g = self.next(g)
        end
      end
    end

    # Returns a FunctionCollection of all the Functions in the module.
    #: -> FunctionCollection
    def functions
      @functions ||= FunctionCollection.new(self)
    end

    class FunctionCollection
      include Enumerable

      def initialize(mod)
        @module = mod
      end

      # Adds a Function with the given name (symbol or string) and args (Types).
      def add(name, *args)
        if args.first.kind_of? FunctionType
          type = args.first
        else
          type = Type.function(
            *args #: as untyped
          )
        end
        function = Function.from_ptr(C.add_function(@module, name.to_s, type))

        if block_given?
          params = (0...function.params.size).map { |i| function.params[i] }
          yield function, *params
        end

        function
      end

      # Returns the Function with the given name (symbol or string).
      #: (String | Symbol) -> Function?
      def named(name)
        ptr = C.get_named_function(@module, name.to_s)
        Function.from_ptr(ptr) unless ptr.null?
      end

      # Returns the first Function in the collection.
      #: -> Function?
      def first
        ptr = C.get_first_function(@module)
        Function.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last Function in the collection.
      #: -> Function?
      def last
        ptr = C.get_last_function(@module)
        Function.from_ptr(ptr) unless ptr.null?
      end

      # Returns the next Function in the collection after function.
      #: (Function) -> Function?
      def next(function)
        ptr = C.get_next_function(function)
        Function.from_ptr(ptr) unless ptr.null?
      end

      # Returns the previous Function in the collection before function.
      #: (Function) -> Function?
      def previous(function)
        ptr = C.get_previous_function(function)
        Function.from_ptr(ptr) unless ptr.null?
      end

      # Deletes the Function from the collection.
      def delete(function)
        C.delete_function(function)
      end

      # Returns the Function with a name equal to key (symbol or string) or at key (integer).
      #: (String | Symbol | Integer) -> Function?
      def [](key)
        case key
        when String, Symbol then named(key)
        when Integer
          i = 0
          f = first #: Function?
          until i >= key || f.nil?
            f = self.next(f)
            i += 1
          end
          f
        end
      end

      # Iterates through each Function in the collection.
      # @override
      #: { (Function) -> void } -> void
      def each(&)
        f = first #: Function?
        until f.nil?
          yield f
          f = self.next(f)
        end
      end
    end

    # Returns the LLVM IR of the module as a string.
    #: -> String
    def to_s
      C.print_module_to_string(self)
    end

    # Returns the LLVM IR of the module as #dump renders it (LLVM's IsForDebug),
    # which differs from #to_s only for declarations, whose parameters #to_s
    # omits.
    #: -> String
    def debug_s
      Support::C.print_module_to_string_debug(self)
    end

    # Print the module's IR to the standard error.
    #
    # Equivalent to LLVMDumpModule, but written through Ruby's $stderr rather
    # than LLVM's errs(), so reassigning $stderr captures it.
    #: -> void
    def dump
      # not warn: warn is silenced by -W0, and an explicit dump must always print
      $stderr.puts(debug_s) # rubocop:disable Style/StderrPuts
    end
  end
end
