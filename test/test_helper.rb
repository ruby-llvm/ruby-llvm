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
    add_filter "/lib/llvm/transforms/scalar.rb"
    add_filter "/lib/llvm/transforms/ipo.rb"
    add_filter "/lib/llvm/transforms/vectorize.rb"
    add_filter "/lib/llvm/transforms/utils.rb"
    add_filter "/lib/llvm/transforms/builder.rb"
    add_filter "/lib/llvm/core/pass_manager.rb"
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

  private

  def with_function(arguments, retty, &block)
    mod = LLVM::Module.new('test')
    fun = mod.functions.add('fun', arguments, retty)
    block.yield(fun)
    mod.dispose
  end

  def create_square_function_module
    LLVM::Module.new('square').tap do |mod|
      mod.functions.add(:square, [LLVM::Int], LLVM::Int) do |fun, x|
        fun.basic_blocks.append.build do |builder|
          n = builder.mul(x, x)
          builder.ret(n)
        end
      end

      mod.verify!
    end
  end

  def create_cube_function_module
    LLVM::Module.new('cube').tap do |mod|
      mod.functions.add(:cube, [LLVM::Int], LLVM::Int) do |fun, x|
        fun.basic_blocks.append.build do |builder|
          n2 = builder.mul(x, x)
          n3 = builder.mul(n2, x)
          builder.ret(n3)
        end
      end

      mod.verify!
    end
  end
end

def define_module(module_name)
  new_module = LLVM::Module.new(module_name)
  yield new_module
  assert_predicate new_module, :valid?
  new_module
end

def define_invalid_module(module_name)
  new_module = LLVM::Module.new(module_name)
  yield new_module
  refute_predicate new_module, :valid?
  new_module
end

def define_function(host_module, function_name, argument_types, return_type)
  function = host_module.functions.add(function_name, argument_types, return_type) do |function, *arguments|
    yield(LLVM::Builder.new, function, *arguments)
  end
  assert_predicate function, :valid?
  function
end

def define_invalid_function(host_module, function_name, argument_types, return_type)
  function = host_module.functions.add(function_name, argument_types, return_type) do |function, *arguments|
    yield(LLVM::Builder.new, function, *arguments)
  end
  refute_predicate function, :valid?
  function
end

def run_function_on_module(host_module, function_name, *argument_values)
  LLVM::MCJITCompiler
    .new(host_module)
    .run_function(host_module.functions[function_name], *argument_values)
end

def run_function(argument_types, argument_values, return_type, &block)
  test_module = define_module("test_module") do |host_module|
    define_function(host_module, "test_function", argument_types, return_type, &block)
  end

  run_function_on_module(test_module, "test_function", *argument_values)
end
