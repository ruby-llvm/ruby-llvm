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
    
    def add_function(name, *args) # arg_types, result_type)
      type = case args[0]
        when Type then args[0]
        else Type.function(*args)
      end
      function = Function.from_ptr(C.LLVMAddFunction(self, name.to_s, type))
      
      if block_given?
        params = (0...function.params.size).map { |i| function.params[i] }
        yield function, *params
      end
      
      function
    end
    
    def named_function(name)
      self.class.from_ptr(C.LLVMGetNamedFunction(self, name))
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
