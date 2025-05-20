# frozen_string_literal: true
# typed: true

require 'ffi'

module LLVM
  require 'llvm/version'
  require 'llvm/support'

  class DeprecationError < StandardError; end

  module PointerIdentity
    # @private
    def to_ptr
      @ptr
    end

    # Checks if the value is equal to other.
    def ==(other)
      other.respond_to?(:to_ptr) &&
          @ptr == other.to_ptr
    end

    # Computes hash.
    def hash
      @ptr.address.hash
    end

    # Checks if the value is equivalent to other.
    def eql?(other)
      self == other
    end
  end
end
