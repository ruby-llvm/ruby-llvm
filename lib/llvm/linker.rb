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
        C.link_modules(other, self, 0, msg)
      end
    end
  end
end
