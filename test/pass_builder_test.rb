# frozen_string_literal: true

require 'test_helper'
require 'llvm/config'
require 'llvm/transforms/pass_builder'
require 'mkmf'

class PassBuilderTest < Minitest::Test
  def setup
    LLVM.init_jit
    @pass_builder = LLVM::PassBuilder.new
    @module = LLVM::Module.new("test")
    LLVM::Target.init_all
    @target = LLVM::Target.by_name('x86-64')
    @tm = @target.create_machine('x86_64-pc-linux-gnu')
  end

  def test_target
    assert @target
  end

  def test_tm
    assert @tm
  end

  def test_no_passes
    @pass_builder.run(@module, @tm)
  end

  def test_no_inline_o0_o3
    1.upto(3) do |o|
      @pass_builder.o!(o)
      refute_includes @pass_builder.pass_string, ',inline,'
    end
  end

  def test_opt_levels
    opt = find_executable "opt-#{LLVM::LLVM_VERSION}"
    skip "No opt binary" if !opt
    LLVM::PassBuilder::OPT_PASSES.each do |level, passes|
      assert_equal passes, `#{opt} -O#{level} -print-pipeline-passes -disable-output < /dev/null`.chomp
    end
  end

  def test_function_pass
    @pass_builder.add_function_pass do |pb|
      pb.basic_aa!.dce!.dse!.licm!.verify!
    end
    assert_equal 'function(require<basic-aa>,dce,dse,licm,verify)', @pass_builder.pass_string
    @pass_builder.run(@module, @tm)
  end

  def test_asan_kernel_pass
    @pass_builder.asan!(kernel: true)
    assert_equal 'asan<kernel>', @pass_builder.pass_string
    @pass_builder.run(@module, @tm)
  end

  def test_msan_kernel_pass
    @pass_builder.msan!(kernel: true)
    assert_equal 'msan<kernel>', @pass_builder.pass_string
    @pass_builder.run(@module, @tm)
  end

  PASSES = LLVM::PassBuilder.new.methods.grep(/\S!$/).freeze
  OLD_PASSES = LLVM::PassManager.new.methods.grep(/\S!$/).freeze
  EXCEPT_PASSES = [:dfsan!, :msan!].freeze

  def test_missing_passes
    missing_passes = OLD_PASSES - PASSES
    assert_equal 0, missing_passes.size, missing_passes
  end

  describe "PassManager Passes" do
    before do
      LLVM.init_jit
      @pass_builder = LLVM::PassBuilder.new
      @module = LLVM::Module.new("test")
      LLVM::Target.init_all
      @target = LLVM::Target.by_name('x86-64')
      assert @tm = @target.create_machine('x86_64-pc-linux-gnu')
    end

    it 'should have target' do
      assert @target
    end

    (PASSES - EXCEPT_PASSES).each do |pass|
      it "should return '#{pass}'" do
        @pass_builder.send(pass)
        @pass_builder.run(@module, @tm)
      end
    end
  end

end
