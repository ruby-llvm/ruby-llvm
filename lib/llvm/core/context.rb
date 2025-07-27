# frozen_string_literal: true
# typed: strict

module LLVM
  class Context
    #: (?FFI::Pointer?) -> void
    def initialize(ptr = nil)
      @ptr = ptr || C.context_create() #: FFI::Pointer?
    end

    # @private
    #: -> FFI::Pointer?
    def to_ptr
      @ptr
    end

    # Obtains a reference to the global Context.
    #: -> Context
    def self.global
      new(C.get_global_context())
    end

    # Diposes the Context.
    #: -> void
    def dispose
      return if @ptr.nil?
      C.context_dispose(@ptr)
      @ptr = nil
    end
  end
end
