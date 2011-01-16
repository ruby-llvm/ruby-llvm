$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

begin
  require "ruby-debug"
rescue LoadError
  # Ignore ruby-debug is case it's not installed
end

require "test/unit"

require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"

class Test::Unit::TestCase

  LLVM_SIGNED = true
  LLVM_UNSIGNED = false

  LLVM_FALSE = 0
  LLVM_TRUE = 1

end

def define_module(module_name)

  new_module = LLVM::Module.create(module_name)

  yield new_module

  new_module.verify

  new_module

end

def define_function(host_module, function_name, argument_types, return_type)

  host_module.functions.add(function_name, argument_types, return_type) do |function, *arguments|
    yield(LLVM::Builder.create, function, *arguments)
  end

end

def run_function_on_module(host_module, function_name, *argument_values)

  LLVM::ExecutionEngine.
    create_jit_compiler(host_module).
    run_function(host_module.functions[function_name], *argument_values)

end

def run_function(argument_types, argument_values, return_type, &block)

  test_module = define_module("test_module") do |host_module|
    define_function(host_module, "test_function", argument_types, return_type, &block)
  end

  run_function_on_module(test_module, "test_function", *argument_values)

end

