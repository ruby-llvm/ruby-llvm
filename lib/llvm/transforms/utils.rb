# frozen_string_literal: true

require 'llvm'
require 'llvm/core'

module LLVM
  class PassManager
    # @LLVMpass lowerswitch
    # /** See llvm::createLowerSwitchPass function. */
    # void LLVMAddLowerSwitchPass(LLVMPassManagerRef PM);
    def lowerswitch!
      raise DeprecationError
    end

    # @LLVMpass mem2reg
    # /** See llvm::createPromoteMemoryToRegisterPass function. */
    # void LLVMAddPromoteMemoryToRegisterPass(LLVMPassManagerRef PM);
    def mem2reg!
      raise DeprecationError
    end

    # @LLVMpass add-discriminators
    # /** See llvm::createAddDiscriminatorsPass function. */
    # void LLVMAddAddDiscriminatorsPass(LLVMPassManagerRef PM);
    def add_discriminators!
      raise DeprecationError
    end
  end
end
