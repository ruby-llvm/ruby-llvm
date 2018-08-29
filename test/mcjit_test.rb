require 'test_helper'

class MCJITTestCase < Minitest::Test
  def setup
    LLVM.init_jit(true)
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

  def test_simple_function
    mod = create_square_function_module

    engine = LLVM::MCJITCompiler.new(mod, :opt_level => 0)

    result = engine.run_function(mod.functions['square'], 5)
    assert_equal 25, result.to_i
  end

  def test_functions_named
    mod = LLVM::Module.new('foo').tap do |mod|
      mod.functions.add(:foo, [], LLVM::Int)
      mod.verify!
    end

    engine = LLVM::MCJITCompiler.new(mod, :opt_level => 0)

    ['foo', :foo].each do |name|
      engine.functions[name].tap do |fun|
        assert fun, "function named #{name.inspect}"
        assert_equal 'foo', fun.name
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
    mod1 = LLVM::Module.new('foo')
    mod2 = LLVM::Module.new('bar')

    foo = mod1.functions.add(:foo, [], LLVM::Int)
    bar = mod2.functions.add(:bar, [], LLVM::Int)

    engine = LLVM::MCJITCompiler.new(mod1, :opt_level => 0)

    (engine.modules << mod2).tap do |ret|
      assert_equal engine.modules, ret, '#<< returns self'
    end

    refute_nil engine.functions[:bar]
    engine.modules.delete(mod2).tap do |ret|
      assert_instance_of LLVM::Module, ret, '#delete returns module'
      assert_equal mod2, ret
    end
    assert_nil engine.functions[:bar]
  end

  def test_accessors
    main_mod = LLVM::Module.new('main')
    engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => 0)
    assert_match(/^e-/, engine.data_layout.to_s)
    assert_match(/gnu/, engine.target_machine.triple)
  end
end
