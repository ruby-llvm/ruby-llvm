# frozen_string_literal: true

module LLVM
  class Context
    def initialize(ptr = nil)
      @ptr = ptr || C.context_create()
    end

    # @private
    def to_ptr
      @ptr
    end

    # Obtains a reference to the global Context.
    def self.global
      new(C.get_global_context())
    end

    # Diposes the Context.
    def dispose
      return if @ptr.nil?
      C.context_dispose(@ptr)
      @ptr = nil
    end
  end
end
