module LLVM
  class Module
    include PointerIdentity

    # @private
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

    # Get module triple.
    #
    # @return [String]
    def triple
      C.get_target(self)
    end

    # Set module triple.
    #
    # @param [String] triple
    def triple=(triple)
      C.set_target(self, triple.to_s)
    end

    # Get module data layout.
    #
    # @return [String]
    def data_layout
      C.get_data_layout(self)
    end

    # Set module data layout.
    #
    # @param [String, TargetDataLayout] data_layout
    def data_layout=(data_layout)
      C.set_data_layout(self, data_layout.to_s)
    end

    # Returns a TypeCollection of all the Types in the module.
    def types
      @types ||= TypeCollection.new(self)
    end

    class TypeCollection
      def initialize(mod)
        @module = mod
      end

      # Returns the Type with the given name (symbol or string).
      def named(name)
        Type.from_ptr(C.get_type_by_name(@module, name.to_s), nil)
      end

      alias [] named
    end

    # Returns an Enumerable of all the GlobalVariables in the module.
    def globals
      @globals ||= GlobalCollection.new(self)
    end

    class GlobalCollection
      include Enumerable

      def initialize(mod)
        @module = mod
      end

      # Adds a GlobalVariable with the given type and name to the collection (symbol or string).
      def add(ty, name)
        GlobalVariable.from_ptr(C.add_global(@module, LLVM::Type(ty), name.to_s)).tap do |gvar|
          yield gvar if block_given?
        end
      end

      # Returns the GlobalVariable with the given name (symbol or string).
      def named(name)
        GlobalValue.from_ptr(C.get_named_global(@module, name.to_s))
      end

      # Returns the first GlobalVariable in the collection.
      def first
        GlobalValue.from_ptr(C.get_first_global(@module))
      end

      # Returns the last GlobalVariable in the collection.
      def last
        GlobalValue.from_ptr(C.get_last_global(@module))
      end

      # Returns the next GlobalVariable in the collection after global.
      def next(global)
        GlobalValue.from_ptr(C.get_next_global(global))
      end

      # Returns the previous GlobalVariable in the collection before global.
      def previous(global)
        GlobalValue.from_ptr(C.get_previous_global(global))
      end

      # Deletes the GlobalVariable from the collection.
      def delete(global)
        C.delete_global(global)
      end

      # Returns the GlobalVariable with a name equal to key (symbol or string) or at key (integer).
      def [](key)
        case key
        when String, Symbol then named(key)
        when Integer then
          i = 0
          g = first
          until i >= key || g.nil?
            g = self.next(g)
            i += 1
          end
          g
        end
      end

      # Iterates through each GlobalVariable in the collection.
      def each
        g = first
        until g.nil?
          yield g
          g = self.next(g)
        end
      end
    end

    # Returns a FunctionCollection of all the Functions in the module.
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
          type = Type.function(*args)
        end
        function = Function.from_ptr(C.add_function(@module, name.to_s, type))

        if block_given?
          params = (0...function.params.size).map { |i| function.params[i] }
          yield function, *params
        end

        function
      end

      # Returns the Function with the given name (symbol or string).
      def named(name)
        Function.from_ptr(C.get_named_function(@module, name.to_s))
      end

      # Returns the first Function in the collection.
      def first
        Function.from_ptr(C.get_first_function(@module))
      end

      # Returns the last Function in the collection.
      def last
        Function.from_ptr(C.get_last_function(@module))
      end

      # Returns the next Function in the collection after function.
      def next(function)
        Function.from_ptr(C.get_next_function(function))
      end

      # Returns the previous Function in the collection before function.
      def previous(function)
        Function.from_ptr(C.get_previous_function(function))
      end

      # Deletes the Function from the collection.
      def delete(function)
        C.delete_function(function)
      end

      # Returns the Function with a name equal to key (symbol or string) or at key (integer).
      def [](key)
        case key
        when String, Symbol then named(key)
        when Integer
          i = 0
          f = first
          until i >= key || f.nil?
            f = self.next(f)
            i += 1
          end
          f
        end
      end

      # Iterates through each Function in the collection.
      def each
        f = first
        until f.nil?
          yield f
          f = self.next(f)
        end
      end
    end

    # Print the module's IR to stdout.
    def dump
      C.dump_module(self)
    end
  end
end
