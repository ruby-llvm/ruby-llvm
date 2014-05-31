require 'test_helper'
require 'llvm/config'
require 'llvm/transforms/builder'

class PassManagerBuilderTest < Minitest::Test
  def setup
    LLVM.init_jit
    @builder = LLVM::PassManagerBuilder.new
  end

  def teardown
    @builder.dispose
  end

  def test_init
    assert_equal  0,     @builder.size_level
    assert_equal  0,     @builder.opt_level
    assert_equal  false, @builder.unit_at_a_time
    assert_equal  false, @builder.unroll_loops
    assert_equal  false, @builder.simplify_lib_calls
    assert_equal  0,     @builder.inliner_threshold
  end

  def test_opt_level
    @builder.opt_level = 3
    assert_equal 3, @builder.opt_level
  end

  def test_build
    machine = LLVM::Target.by_name('x86-64').create_machine('x86-linux-gnu')
    pass_manager = LLVM::PassManager.new(machine)
    @builder.build(pass_manager)
  end

  def test_build_with_lto
    machine = LLVM::Target.by_name('x86-64').create_machine('x86-linux-gnu')
    pass_manager = LLVM::PassManager.new(machine)
    @builder.build_with_lto(pass_manager)
  end
end
