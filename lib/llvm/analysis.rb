# frozen_string_literal: true
# typed: strict

require 'llvm'
require 'llvm/core'
require 'llvm/target'
require 'llvm/analysis_ffi'

module LLVM
  class Module
    # Verify that the module is valid.
    # @return [nil, String] human-readable description of any invalid
    #   constructs if invalid.
    #: -> String?
    def verify
      do_verification(:return_status)
    end

    # Verify that a module is valid, and abort the process if not.
    # @return [nil]
    #: -> String?
    def verify!
      # :nocov:
      do_verification(:abort_process)
      # :nocov:
    end

    #: -> bool
    def valid?
      verify.nil?
    end

    private

    #: (Symbol) -> String?
    def do_verification(action)
      LLVM.with_message_output do |str|
        C.verify_module(self, action, str)
      end
    end
  end

  class Function
    # Verify that a function is valid.
    # @return [true, false]
    #: -> bool
    def verify
      do_verification(:return_status)
    end

    # Verify that a function is valid, and abort the process if not.
    # @return [true, false]
    #: -> bool
    def verify!
      # :nocov:
      do_verification(:abort_process)
      # :nocov:
    end

    #: -> bool
    def valid?
      verify
    end

    private

    #: (Symbol) -> bool
    def do_verification(action)
      C.verify_function(self, action).zero?
    end
  end
end
