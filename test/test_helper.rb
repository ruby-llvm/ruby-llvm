$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "test/unit"

require "llvm/core"
require "llvm/execution_engine"
require "llvm/transforms/scalar"

def run_function(argument_types, argument_values, return_type)

  test_module = LLVM::Module.create("test_module")

  test_module.functions.add("test_function", argument_types, return_type) do |function, *arguments|
    yield(LLVM::Builder.create, function, *arguments)
  end

  test_module.verify

  engine = LLVM::ExecutionEngine.create_jit_compiler(test_module)

  engine.run_function(test_module.functions["test_function"], *argument_values)

end
