# frozen_string_literal: true
# typed: true

require 'test_helper'

class MCJITTestCase < Minitest::Test
  def setup
    LLVM.init_jit(true)
  end

  def test_simple_function
    mod = create_square_function_module

    engine = LLVM::MCJITCompiler.new(mod, :opt_level => 0)

    result = engine.run_function(mod.functions['square'], 5)
    assert_equal 25, result.to_i
  end

  def test_functions_named
    mod = create_square_function_module

    engine = LLVM::MCJITCompiler.new(mod, :opt_level => 0)

    ['square', :square].each do |name|
      engine.functions[name].tap do |fun|
        assert fun, "function named #{name.inspect} exists"
        assert_equal name.to_s, fun.name
      end
    end
  end

  def test_add_module
    main_mod = LLVM::Module.new('main')

    main_mod.functions.add(:square, [LLVM::Int], LLVM::Int) do |square|
      main_mod.functions.add(:call_square, [], LLVM::Int) do |call_square|
        call_square.basic_blocks.append.build do |builder|
          n = builder.call(square, LLVM::Int(5))
          builder.ret(n)
        end
      end
    end

    main_mod.verify!

    engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => 0)
    engine.modules << create_square_function_module

    result = engine.run_function(main_mod.functions['call_square'])
    assert_equal 25, result.to_i
  end

  def test_remove_module
    mod1 = create_square_function_module
    mod2 = create_cube_function_module

    engine = LLVM::MCJITCompiler.new(mod1, :opt_level => 0)

    (engine.modules << mod2).tap do |ret|
      assert_equal engine.modules, ret, '#<< returns self'
    end

    refute_nil engine.functions[:cube]
    engine.modules.delete(mod2).tap do |ret|
      assert_instance_of LLVM::Module, ret, '#delete returns module'
      assert_equal mod2, ret
    end
    assert_nil engine.functions[:cube]
  end

  def test_accessors
    main_mod = LLVM::Module.new('main')
    engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => 0)
    assert_match(/^e-/, engine.data_layout.to_s)
    matcher = case FFI::Platform::OS
    when 'darwin'
      /apple-darwin/
    when 'linux'
      /gnu/
    else
      raise "New platform: #{FFI::Platform::OS}"
    end
    assert_match(matcher, engine.target_machine.triple)
  end
end
