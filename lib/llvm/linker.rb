# frozen_string_literal: true
# typed: strict

require 'llvm'
require 'llvm/core'
require 'llvm/linker_ffi'

module LLVM
  class Module
    # Link the current module into +other+.
    #
    # @return [nil, String] human-readable error if linking has failed
    #: (LLVM::Module) -> String?
    def link_into(other)
      LLVM.with_message_output do |msg|
        C.link_modules2(other, self)
      end
    end
  end
end
