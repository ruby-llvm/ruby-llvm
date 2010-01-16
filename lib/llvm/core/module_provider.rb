module LLVM
  class ModuleProvider
    class << self
      private :new
    end
    
    def initialize(ptr)
      @ptr = ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.for_existing_module(mod)
      new(C.LLVMCreateModuleProviderForExistingModule(mod))
    end
  end
end
