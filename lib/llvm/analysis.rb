require 'llvm'
require 'llvm/core'
require 'llvm/target'

module LLVM
  # @private
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
    # Verify that the module is valid.
    # @return [nil, String] human-readable description of any invalid
    #   constructs if invalid.
    def verify
      do_verification(:return_status)
    end
    
    # Verify that a module is valid, and abort the process if not.
    # @return [nil]
    def verify!
      do_verification(:abort_process)
    end
    
    private
      def do_verification(action)
        result = nil
        FFI::MemoryPointer.new(FFI.type_size(:pointer)) do |str|
          status = C.LLVMVerifyModule(self, action, str)
          result = str.read_string if status == 1
          C.LLVMDisposeMessage str.read_pointer
        end
        result
      end
  end
  
  class Function
    # Verify that a function is valid.
    # @return [true, false]
    def verify
      do_verification(:return_status)
    end

    # Verify that a function is valid, and abort the process if not.
    # @return [true, false]
    def verify!
      do_verification(:abort_process)
    end

    private

    def do_verification(action)
      C.LLVMVerifyFunction(self, action) != 0
    end
  end
end
