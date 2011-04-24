module LLVM  
  class Context
    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end
    
    # @private
    def to_ptr
      @ptr
    end
    
    # Creates a new Context.
    def self.create
      new(C.LLVMContextCreate())
    end
    
    # Obtains a reference to the global Context.
    def self.global
      new(C.LLVMGetGlobalContext())
    end
    
    # Diposes the Context.
    def dispose
      C.LLVMContextDispose(@ptr)
    end
  end
end
