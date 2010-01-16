module LLVM  
  class PassManager
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def self.new_with_execution_engine(engine)
      ptr = C.LLVMCreatePassManager()
      C.LLVMAddTargetData(
        C.LLVMGetExecutionEngineTargetData(engine), ptr)
      new(ptr)
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def run(mod)
      C.LLVMRunPassManager(self, mod)
    end
  end
end
