require "test_helper"

class CallTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_simple_call
    test_module = define_module("test_module") do |host_module|
      define_function(host_module, "test_function", [], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(1))
      end
    end
    assert_equal 1, run_function_on_module(test_module, "test_function").to_i
  end

  def test_nested_call
    test_module = define_module("test_module") do |host_module|
      function_1 = define_function(host_module, "test_function_1", [], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(1))
      end
      function_2 = define_function(host_module, "test_function_2", [], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(builder.call(function_1))
      end
    end
    assert_equal 1, run_function_on_module(test_module, "test_function_2").to_i
  end

  def test_recursive_call
    test_module = define_module("test_module") do |host_module|
      define_function(host_module, "test_function", [LLVM::Int], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        recurse = function.basic_blocks.append
        exit = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.cond(builder.icmp(:uge, arguments.first, LLVM::Int(5)), exit, recurse)
        builder.position_at_end(recurse)
        result = builder.call(function, builder.add(arguments.first, LLVM::Int(1)))
        builder.br(exit)
        builder.position_at_end(exit)
        builder.ret(builder.phi(LLVM::Int, arguments.first, entry, result, recurse))
      end
    end
    assert_equal 5, run_function_on_module(test_module, "test_function", 1).to_i
  end

  def test_external
    test_module = define_module("test_module") do |host_module|
      external = host_module.functions.add("abs", [LLVM::Int32], LLVM::Int32)
      define_function(host_module, "test_function", [LLVM::Int32], LLVM::Int32) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(builder.call(external, arguments.first))
      end
    end
    assert_equal -10.abs, run_function_on_module(test_module, "test_function", -10).to_i
  end

  def test_external_string
    test_module = define_module("test_module") do |host_module|
      global = host_module.globals.add(LLVM::Array(LLVM::Int8, 5), "path")
      global.linkage = :internal
      global.initializer = LLVM::ConstantArray.string("PATH")
      external = host_module.functions.add("getenv", [LLVM::Pointer(LLVM::Int8)], LLVM::Pointer(LLVM::Int8))
      define_function(host_module, "test_function", [], LLVM::Pointer(LLVM::Int8)) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        parameter = builder.gep(global, [LLVM::Int(0), LLVM::Int(0)])
        builder.ret(builder.call(external, parameter))
      end
    end
    assert_equal ENV["PATH"], run_function_on_module(test_module, "test_function").to_ptr.read_pointer.read_string
  end

end
