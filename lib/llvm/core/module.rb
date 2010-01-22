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
    
    def self.create_with_name(name)
      new(C.LLVMModuleCreateWithName(name))
    end
    
    def self.create_with_name_in_context(name, context)
      new(C.LLVMModuleCreateWithNameInContext(name, context))
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
        type = case args[0]
          when Type then args[0]
          else Type.function(*args)
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
