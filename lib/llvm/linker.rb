# frozen_string_literal: true
# typed: strict

require 'llvm'
require 'llvm/core'
require 'llvm/linker_ffi'

module LLVM
  class Module
    # Link the current module into +other+. LLVM destroys the current module,
    # so afterward it is cleared as if disposed, and must not be used.
    #
    # @return [Boolean] true if linking succeeded; the inverse of
    #   LLVMLinkModules2, which returns true if an error occurred. A failed
    #   link ends the process, because LLVM's default diagnostic handler
    #   prints the error and exits; false is returned only if a diagnostic
    #   handler is installed on the context. See
    #   https://github.com/ruby-llvm/ruby-llvm/issues/346
    #: (LLVM::Module) -> bool
    def link_into(other)
      succeeded = C.link_modules2(other, self).zero?
      @ptr = nil #: FFI::Pointer?
      succeeded
    end
  end
end
