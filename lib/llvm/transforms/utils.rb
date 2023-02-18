# frozen_string_literal: true

require 'llvm'
require 'llvm/core'

module LLVM
  class PassManager

    # @LLVMpass lowerswitch
    # /** See llvm::createLowerSwitchPass function. */
    # void LLVMAddLowerSwitchPass(LLVMPassManagerRef PM);
    def lowerswitch!
      C.add_lower_switch_pass(self)
    end

    # @LLVMpass mem2reg
    # /** See llvm::createPromoteMemoryToRegisterPass function. */
    # void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM);
    def mem2reg!
      C.add_promote_memory_to_register_pass(self)
    end

    # @LLVMpass add-discriminators
    # /** See llvm::createAddDiscriminatorsPass function. */
    # void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM);
    def add_discriminators!
      C.add_add_discriminators_pass(self)
    end
  end

  module C
    attach_function :add_add_discriminators_pass, :LLVMAddAddDiscriminatorsPass, [:pointer], :void
  end
end
