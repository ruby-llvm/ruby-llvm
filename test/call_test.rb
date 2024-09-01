# frozen_string_literal: true

require "test_helper"

class CallTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  def test_simple_call
    test_module = define_module("test_module") do |host_module|
      define_function(host_module, "test_function", [], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(1))
      end
    end
    assert function = test_module.functions["test_function"]
    assert_equal :function, function.type.kind
    assert_equal 'i32 ()', function.type.to_s
    assert_equal :function, function.function_type.kind
    assert_equal 'i32 ()', function.function_type.to_s
    assert_equal :integer, function.return_type.kind
    assert_equal 'i32', function.return_type.to_s
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
        builder.ret(builder.phi(LLVM::Int, entry => arguments.first, recurse => result))
      end
    end
    assert_equal 5, run_function_on_module(test_module, "test_function", 1).to_i
  end

  def test_external
    test_module = define_module("test_module") do |host_module|
      external = host_module.functions.add("abs", [LLVM::Int], LLVM::Int)
      define_function(host_module, "test_function", [LLVM::Int], LLVM::Int) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(builder.call(external, arguments.first))
      end
    end
    assert_equal(-10.abs, run_function_on_module(test_module, "test_function", -10).to_i)
  end

  def test_external_string
    test_module = define_module("test_module") do |host_module|
      global = host_module.globals.add(LLVM::Array(LLVM::Int8, 5), "path")
      global.linkage = :internal
      global.initializer = LLVM::ConstantArray.string("PATH")
      refute_predicate global, :thread_local?
      external = host_module.functions.add("getenv", [LLVM::Pointer(LLVM::Int8)], LLVM::Pointer(LLVM::Int8))
      define_function(host_module, "test_function", [], LLVM::Pointer(LLVM::Int8)) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        parameter = builder.gep(global, [LLVM::Int(0), LLVM::Int(0)])
        builder.ret(builder.call(external, parameter))
      end
    end
    assert_equal ENV.fetch("PATH", nil), run_function_on_module(test_module, "test_function").to_ptr.read_pointer.read_string
  end

  def test_call_with_nonfunction
    test_module = define_module("test_module") do |host_module|
      define_function(host_module, "test_function", [], LLVM.Void) do |builder, function|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        assert_raises(ArgumentError) do
          builder.call(nil)
        end
        assert_raises(ArgumentError) do
          builder.call("test")
        end
        assert_raises(ArgumentError) do
          builder.call(LLVM::Int64.from_i(0))
        end
        builder.ret nil
      end
    end
  end

  def test_call_default_call_conv
    test_module = define_module("test_module") do |host_module|
      callee_fun = define_function(host_module, "callee_fun", [LLVM::Int64], LLVM::Int64) do |builder, function, *arguments|
        function.call_conv = :fast
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(arguments[0])
      end

      define_function(host_module, "caller_fun", [], LLVM::Int64) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(builder.call(callee_fun, LLVM::Int64.from_i(42)))
      end
    end

    assert function = test_module.functions["caller_fun"]
    assert_match(/call fastcc i64 @callee_fun/, function.to_s)
    assert_equal 42, run_function_on_module(test_module, "caller_fun").to_i
  end

  def test_call_by_function_name
    test_module = define_module("test_module") do |host_module|
      define_function(host_module, "callee_fun", [LLVM::Int64], LLVM::Int64) do |builder, function, *arguments|
        function.call_conv = :fast
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(arguments[0])
      end

      define_function(host_module, "caller_fun", [], LLVM::Int64) do |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(builder.call('callee_fun', LLVM::Int64.from_i(42)))
      end
    end

    assert function = test_module.functions["caller_fun"]
    assert_match(/call fastcc i64 @callee_fun/, function.to_s)
    assert_equal 42, run_function_on_module(test_module, "caller_fun").to_i
  end

  def test_invoke_missing_personality_function
    test_module = define_invalid_module("test_module") do |host_module|
      callee_fun = define_function(host_module, "callee_fun", [], LLVM::Int64) do |builder, function, *arguments|
        function.call_conv = :fast
        entry = function.basic_blocks.append('entry')
        builder.position_at_end(entry)
        builder.ret(LLVM::Int64.from_i(42))
      end

      # invalid because no personality function is set
      caller_fun = define_invalid_function(host_module, "caller_fun", [], LLVM::Int64) do |builder, function, *arguments|
        entry = function.basic_blocks.append('entry')
        normal = function.basic_blocks.append('normal')
        exception = function.basic_blocks.append('exception')
        entry.build do |b|
          b.invoke(callee_fun, [], normal, exception, 'invoking')
        end
        normal.build do |b|
          b.ret LLVM::Int64.from_i(0)
        end
        exception.build do |b|
          b.landing_pad_cleanup(LLVM::Int64, nil, 0)
          b.ret LLVM::Int64.from_i(-1)
        end
      end
    end

    assert function = test_module.functions["caller_fun"]
    assert_match(/%invoking = invoke fastcc i64 @callee_fun()/, function.to_s)
    assert_match(/^LandingPadInst needs to be in a function with a personality.\n/, test_module.verify)

    # cannot run invalid module
    # assert_equal 42, run_function_on_module(test_module, "callee_fun").to_i
    # assert_equal 42, run_function_on_module(test_module, "caller_fun").to_i
  end
end
