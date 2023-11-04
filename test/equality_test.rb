# frozen_string_literal: true

require "test_helper"
require "llvm/core"

class EqualityTestCase < Minitest::Test
  def setup
    LLVM.init_jit
  end

  class MyModule < LLVM::Module; end
  class MyInt < LLVM::Int32; end
  class MyType < LLVM::Type; end
  class MyFunction < LLVM::Function; end

  def assert_equalities(options)
    map = {
      :equal     => method(:assert_equal),
      :not_equal => lambda {|n, m, name| assert_operator n, :!=, m, name },
      :same      => method(:assert_same),
      :not_same  => lambda {|n, m, name| assert !n.equal?(m), name },
      :eql       => lambda {|n, m, name| assert n.eql?(m), name  },
      :not_eql   => lambda {|n, m, name| assert !n.eql?(m), name },
    }

    map.each do |name, callable|
      options[name].combination(2).each do |n, m|
        callable.call(n, m, name.to_s)
      end
    end
  end

  def test_int_value
    int1 = LLVM::Int32.from_i(1)
    int2 = LLVM::Int32.from_ptr(int1.to_ptr)
    int3 = LLVM::Int32.from_i(2)
    int4 = MyInt.from_ptr(int1.to_ptr)

    assert_equalities :equal     => [int1, int2, int4],
                      :not_equal => [int1, int3],
                      :same      => [int1, int1],
                      :not_same  => [int1, int2, int3, int4],
                      :eql       => [int1, int2],
                      :not_eql   => [int1, int3]
  end

  def test_module
    mod1 = LLVM::Module.new('test')
    mod2 = LLVM::Module.from_ptr(mod1.to_ptr)
    mod3 = LLVM::Module.new('dummy')
    mod4 = MyModule.from_ptr(mod1.to_ptr)

    assert_equalities :equal     => [mod1, mod2, mod4],
                      :not_equal => [mod1, mod3],
                      :same      => [mod1, mod1],
                      :not_same  => [mod1, mod2, mod3, mod4],
                      :eql       => [mod1, mod2],
                      :not_eql   => [mod1, mod3]
  end

  def test_type
    type1 = LLVM::Float.type
    type2 = LLVM::Type.from_ptr(type1.to_ptr, nil)
    type3 = LLVM::Double.type
    type4 = MyType.from_ptr(type1.to_ptr, :mytype)

    assert_equalities :equal     => [type1, type2, type4],
                      :not_equal => [type1, type3],
                      :same      => [type1, type1],
                      :not_same  => [type1, type2, type3, type4],
                      :eql       => [type1, type2],
                      :not_eql   => [type1, type3]
  end

  def test_function
    mod = LLVM::Module.new('test')

    fn1 = mod.functions.add('test1', [], LLVM.Void)
    fn2 = LLVM::Function.from_ptr(fn1.to_ptr)
    fn3 = mod.functions.add('test2', [], LLVM.Void)
    fn4 = MyFunction.from_ptr(fn1.to_ptr)

    assert_equalities :equal     => [fn1, fn2, fn4],
                      :not_equal => [fn1, fn3],
                      :same      => [fn1, fn1],
                      :not_same  => [fn1, fn2, fn3, fn4],
                      :eql       => [fn1, fn2],
                      :not_eql   => [fn1, fn3]
  end

end
