require 'llvm'
require 'llvm/core'
require 'llvm/target'

module LLVM
  module C
    enum :verifier_failure_action, [
      :abort_process,
      :print_message,
      :return_status
    ]
    
    attach_function :LLVMVerifyModule, [:pointer, :verifier_failure_action, :pointer], :int
    attach_function :LLVMVerifyFunction, [:pointer, :verifier_failure_action], :int
  end
  
  class Module
    def verify
      do_verification(:return_status)
    end
    
    def verify!
      do_verification(:abort_process)
    end
    
    private
      def do_verification(action)
        str = FFI::MemoryPointer.new(FFI.type_size(:pointer))
        status = C.LLVMVerifyModule(self, action, str)
        case status
          when 1 then str.read_string
          else nil
        end
      end
  end
  
  class Function
    def verify(action = :abort)
      str = FFI::MemoryPointer.new(FFI.type_size(:pointer))
      case status = C.LLVMVerifyFunction(self, action, str)
        when 1 then str.read_string
        else nil
      end
    end
  end
end
