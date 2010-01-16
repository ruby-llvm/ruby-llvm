require 'llvm'
require 'llvm/core'
require 'llvm/target'

module LLVM
  module C
    ffi_lib 'LLVMAnalysis'
    
    attach_function :LLVMVerifyModule, [:pointer, :int, :pointer], :int
    attach_function :LLVMVerifyFunction, [:pointer, :int, :pointer], :int
  end
  
  LLVMVerifierFailureAction = [
    LLVMAbortProcessAction = 0,
    LLVMPrintMessageAction = 1,
    LLVMReturnStatusAction = 2
  ]
  
  def verifier_action(action)
    case action
      when *LLVMVerifierFailureAction then action
      when :abort  then LLVMAbortProcessAction
      when :print  then LLVMPrintMessageAction
      when :return then LLVMReturnStatusAction
      else raise ArgumentError, "Unknown verifier action #{action}"
    end
  end
  module_function :verifier_action
  
  class Module
    def verify
      do_verification(:return)
    end
    
    def verify!
      do_verification(:abort)
    end
    
    private
      def do_verification(action)
        str = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status = C.LLVMVerifyModule(self, LLVM::verifier_action(action), str)
        case status
          when 1 then str.read_string
          else nil
        end
      end
  end
  
  class Function
    def verify(action = :abort)
      str = FFI::MemoryPointer.new(FFI.type_size(:pointer))
      case status = C.LLVMVerifyFunction(self, LLVM::verifier_action(action), str)
        when 1 then str.read_string
        else nil
      end
    end
  end
end
