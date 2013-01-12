require 'llvm'
require 'llvm/core'
require 'llvm/linker_ffi'

module LLVM
  class Module
    # Link the current module into +other+.
    #
    # @return [nil, String] human-readable error if linking has failed
    def link_into(other)
      LLVM.with_message_output do |msg|
        # HACK ALERT: ffi-gen missed LLVMLinkerPreserveSource enumeration for
        # some reason. It is inlined as a constant here.

        # C.link_modules(mod, self, :linker_preserve_source, msg)
        C.link_modules(other, self, 1, msg)
      end
    end

    # Link the current module into +other+, and dispose the current module.
    #
    # @return [nil, String] human-readable error if linking has failed
    def link_into_and_destroy(other)
      result = LLVM.with_message_output do |msg|
        # HACK ALERT: ffi-gen missed LLVMLinkerPreserveSource enumeration for
        # some reason. It is inlined as a constant here.
        C.link_modules(other, self, :linker_destroy_source, msg)
      end

      @ptr = nil

      result
    end
  end
end