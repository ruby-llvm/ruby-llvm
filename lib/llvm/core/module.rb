module LLVM  
  class Module
    class << self
      private :new
    end
    
    def self.from_ptr(ptr)
      ptr.null? ? nil : new(ptr)
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.create(name)
      new(C.LLVMModuleCreateWithName(name))
    end
    
    def types
      @types ||= TypeCollection.new(self)
    end
    
    class TypeCollection
      def initialize(mod)
        @module = mod
      end
      
      def add(name, type)
        C.LLVMAddTypeName(@module, name.to_s, type)
      end
      
      def named(name)
        Type.from_ptr(C.LLVMGetTypeByName(@module, name))
      end
      
      def [](key)
        case key
        when String then named(key)
        when Symbol then named(key.to_s)
        end
      end
      
      def []=(key, type)
        add(key, type)
      end
    end
    
    def globals
      @globals ||= GlobalCollection.new(self)
    end
    
    class GlobalCollection
      include Enumerable
      
      def initialize(mod)
        @module = mod
      end
      
      def add(ty, name)
        GlobalVariable.from_ptr(C.LLVMAddGlobal(@module, LLVM::Type(ty), name))
      end
      
      def named(name)
        GlobalValue.from_ptr(C.LLVMGetNamedGlobal(@module, name))
      end
      
      def first
        GlobalValue.from_ptr(C.LLVMGetFirstGlobal(@module))
      end
      
      def last
        GlobalValue.from_ptr(C.LLVMGetLastGlobal(@module))
      end
      
      def next(global)
        GlobalValue.from_ptr(C.LLVMGetNextGlobal(global))
      end
      
      def previous(global)
        GlobalValue.from_ptr(C.LLVMGetPreviousGlobal(global))
      end
      
      def delete(global)
        C.LLVMDeleteGlobal(global)
      end
      
      def [](key)
        case key
        when String then named(key)
        when Symbol then named(key.to_s)
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
      
      def each
        g = first
        until g.nil?
          yield g
          g = self.next(g)
        end
      end
    end
    
    def functions
      @functions ||= FunctionCollection.new(self)
    end
    
    class FunctionCollection
      include Enumerable
      
      def initialize(mod)
        @module = mod
      end
      
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
      
      def named(name)
        Function.from_ptr(C.LLVMGetNamedFunction(@module, name))
      end
      
      def first
        Function.from_ptr(C.LLVMGetFirstFunction(@module))
      end
      
      def last
        Function.from_ptr(C.LLVMGetLastFunction(@module))
      end
      
      def next(function)
        Function.from_ptr(C.LLVMGetNextFunction(function))
      end
      
      def previous(function)
        Function.from_ptr(C.LLVMGetPreviousFunction(function))
      end
      
      def delete(function)
        C.LLVMDeleteFunction(function)
      end
      
      def [](key)
        case key
        when String then named(key)
        when Symbol then named(key.to_s)
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
      
      def each
        f = first
        until f.nil?
          yield f
          f = self.next(f)
        end
      end
    end
    
    # Print the module's IR to stdout
    def dump
      C.LLVMDumpModule(self)
    end
    
    def dispose
      C.LLVMDisposeModule(@ptr)
    end
  end
end
