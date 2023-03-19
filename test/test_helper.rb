# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

begin
  require 'simplecov'

  SimpleCov.start do
    add_filter "/test/"
  end
rescue LoadError
  warn "Proceeding without SimpleCov. gem install simplecov on supported platforms."
end

require "minitest/autorun"
require 'minitest/reporters'

if !ENV['RM_INFO']
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
end

require "llvm/core"
require "llvm/execution_engine"

class Minitest::Test

  LLVM_SIGNED = true
  LLVM_UNSIGNED = false

  LLVM_FALSE = 0
  LLVM_TRUE = 1

end

def define_module(module_name)
  new_module = LLVM::Module.new(module_name)
  yield new_module
  assert_predicate new_module, :valid?
  new_module
end

def define_function(host_module, function_name, argument_types, return_type)
  function = host_module.functions.add(function_name, argument_types, return_type) do |function, *arguments|
    yield(LLVM::Builder.new, function, *arguments)
  end
  assert_predicate function, :valid?
  function
end

def run_function_on_module(host_module, function_name, *argument_values)
  LLVM::MCJITCompiler.new(host_module).
    run_function(host_module.functions[function_name], *argument_values)
end

def run_function(argument_types, argument_values, return_type, &block)
  test_module = define_module("test_module") do |host_module|
    define_function(host_module, "test_function", argument_types, return_type, &block)
  end

  run_function_on_module(test_module, "test_function", *argument_values)
end
