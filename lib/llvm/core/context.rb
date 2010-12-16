module LLVM  
  class Context
    private_class_method :new

    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    # Creates a new Context
    def self.create
      new(C.LLVMContextCreate())
    end
    
    # Obtains a reference to the global Context
    def self.global
      new(C.LLVMGetGlobalContext())
    end
    
    def dispose
      C.LLVMContextDispose(@ptr)
    end
  end
end
