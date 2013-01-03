require 'llvm'
require 'llvm/core_ffi'
require 'llvm/support'

module LLVM
  # @private
  module C
    attach_function :dispose_message, :LLVMDisposeMessage, [:pointer], :void
  end
  
  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/core/bitcode'
end
