module LLVM  
  class Context
    def initialize
      @ptr = C.LLVMContextCreate()
    end

    # @private
    def to_ptr
      @ptr
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
