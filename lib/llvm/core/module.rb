module LLVM  
  class Module
    # @private
    def self.from_ptr(ptr)
      return if ptr.null?
      mod = allocate
      mod.instance_variable_set(:@ptr, ptr)
      mod
    end
    
    def initialize(name)
      @ptr = C.LLVMModuleCreateWithName(name)
    end
    
    # @private
    def to_ptr
      @ptr
    end
    
    # Checks if the module is equal to other.
    def ==(other)
      case other
      when LLVM::Module
        @ptr == other.to_ptr
      else
        false
      end
    end

    # Checks if the module is equal to other.
    def eql?(other)
      other.instance_of?(self.class) && self == other
    end

    # Returns a TypeCollection of all the Types in the module.
    def types
      @types ||= TypeCollection.new(self)
    end
    
    class TypeCollection
      def initialize(mod)
        @module = mod
      end
      
      # Adds the given Type to the collection with the given name (symbol or string).
      def add(name, type)
        C.LLVMAddTypeName(@module, name.to_s, type)
      end
      
      # Returns the Type with the given name (symbol or string).
      def named(name)
        Type.from_ptr(C.LLVMGetTypeByName(@module, name.to_s))
      end
      
      # Returns the Type with the a name equal to key (symbol or string).
      def [](key)
        named(key)
      end
      
      # Adds the given Type to the collection with a name equal to key (symbol or string).
      def []=(key, type)
        add(key, type)
      end
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
        GlobalVariable.from_ptr(C.LLVMAddGlobal(@module, LLVM::Type(ty), name.to_s))
      end
      
      # Returns the GlobalVariable with the given name (symbol or string).
      def named(name)
        GlobalValue.from_ptr(C.LLVMGetNamedGlobal(@module, name.to_s))
      end
      
      # Returns the first GlobalVariable in the collection.
      def first
        GlobalValue.from_ptr(C.LLVMGetFirstGlobal(@module))
      end
      
      # Returns the last GlobalVariable in the collection.
      def last
        GlobalValue.from_ptr(C.LLVMGetLastGlobal(@module))
      end
      
      # Returns the next GlobalVariable in the collection after global.
      def next(global)
        GlobalValue.from_ptr(C.LLVMGetNextGlobal(global))
      end
      
      # Returns the previous GlobalVariable in the collection before global.
      def previous(global)
        GlobalValue.from_ptr(C.LLVMGetPreviousGlobal(global))
      end
      
      # Deletes the GlobalVariable from the collection.
      def delete(global)
        C.LLVMDeleteGlobal(global)
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
        if args.first.kind_of? Type
          type = args.first
        else
          type = Type.function(*args)
        end
        function = Function.from_ptr(C.LLVMAddFunction(@module, name.to_s, type))
        
        if block_given?
          params = (0...function.params.size).map { |i| function.params[i] }
          yield function, *params
        end
        
        function        
      end
      
      # Returns the Function with the given name (symbol or string).
      def named(name)
        Function.from_ptr(C.LLVMGetNamedFunction(@module, name.to_s))
      end
      
      # Returns the first Function in the collection.
      def first
        Function.from_ptr(C.LLVMGetFirstFunction(@module))
      end
      
      # Returns the last Function in the collection.
      def last
        Function.from_ptr(C.LLVMGetLastFunction(@module))
      end
      
      # Returns the next Function in the collection after function.
      def next(function)
        Function.from_ptr(C.LLVMGetNextFunction(function))
      end
      
      # Returns the previous Function in the collection before function.
      def previous(function)
        Function.from_ptr(C.LLVMGetPreviousFunction(function))
      end
      
      # Deletes the Function from the collection.
      def delete(function)
        C.LLVMDeleteFunction(function)
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
      C.LLVMDumpModule(self)
    end
    
    # Dispose the module.
    def dispose
      C.LLVMDisposeModule(@ptr)
    end
  end
end
