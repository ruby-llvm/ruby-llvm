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
        C.link_modules(other, self, :preserve_source, msg)
      end
    end

    # Link the current module into +other+, and dispose the current module.
    #
    # @return [nil, String] human-readable error if linking has failed
    def link_into_and_destroy(other)
      result = LLVM.with_message_output do |msg|
        C.link_modules(other, self, :destroy_source, msg)
      end

      @ptr = nil

      result
    end
  end
end
