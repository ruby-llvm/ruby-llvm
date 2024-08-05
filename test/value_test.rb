# frozen_string_literal: true

require "test_helper"

class ValueTestCase < Minitest::Test

  extend Minitest::Spec::DSL

  TO_S_TESTS = [
    [LLVM::FALSE, 'i1 false'],
    [LLVM::TRUE, 'i1 true'],
    [LLVM.Void, 'void'],
  ].freeze

  describe "LLVM::Type#to_s" do
    TO_S_TESTS.each do |(value, string)|
      it "should return '#{string}'" do
        # assert_instance_of LLVM::Value, value
        assert_equal string, value.to_s
      end
    end
  end

end
