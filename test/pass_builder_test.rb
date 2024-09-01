# frozen_string_literal: true

require 'test_helper'
require 'llvm/config'
require 'llvm/pass_builder'
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

  # as of 18, always-inline is present in 0-3 by default
  # inliner is present in 1-3
  def test_default_inlining
    0.upto(3) do |opt_level|
      @pass_builder.o!(opt_level)
      assert_includes @pass_builder.passes.last, 'always-inline,'
      assert_equal opt_level != 0, @pass_builder.passes.last.include?('devirt<4>(inline,')
      assert_equal LLVM::PassBuilder::OPT_PASSES[opt_level.to_s], @pass_builder.passes.last
    end
  end

  # o! with disable_always_inline removes always_inline
  def test_disable_always_inline
    0.upto(3) do |opt_level|
      @pass_builder.o!(opt_level, disable_always_inline: true)
      refute_includes @pass_builder.passes.last, 'always-inline'
      assert_equal opt_level != 0, @pass_builder.passes.last.include?('devirt<4>(inline,')
      assert_equal LLVM::PassBuilder::OPT_PASSES[opt_level.to_s].gsub('always-inline,', ''), @pass_builder.passes.last
    end
  end

  # o! with disable_inline removes inline
  def test_disable_inline
    0.upto(3) do |opt_level|
      @pass_builder.o!(opt_level, disable_inline: true)
      assert_includes @pass_builder.passes.last, 'always-inline'
      refute_includes @pass_builder.passes.last, 'devirt<4>(inline,'
      assert_equal LLVM::PassBuilder::OPT_PASSES[opt_level.to_s].gsub('devirt<4>(inline,', 'devirt<4>('), @pass_builder.passes.last
    end
  end

  # o! with disable_inline and disable_always_inline removes inlining
  def test_disable_all_inlining
    0.upto(3) do |opt_level|
      @pass_builder.o!(opt_level, disable_always_inline: true, disable_inline: true)
      refute_includes @pass_builder.pass_string, 'inline'
      expected = LLVM::PassBuilder::OPT_PASSES[opt_level.to_s].sub('always-inline,', '').sub('inline,', '')
      assert_equal expected, @pass_builder.passes.last
    end
  end

  def test_opt_levels
    opt = find_executable "opt-#{LLVM::LLVM_VERSION}"
    skip "No opt binary" if !opt
    LLVM::PassBuilder::OPT_PASSES.each do |level, passes|
      assert_equal passes, `#{opt} -O#{level} -print-pipeline-passes -disable-output < /dev/null`.chomp
    end
  end

  def test_inliner_threshold
    @pass_builder.inliner_threshold = 10
    @pass_builder.o!
    @pass_builder.run(@module, @tm)
  end

  def test_inliner_threshold_disable_always_inline
    @pass_builder.inliner_threshold = 10
    @pass_builder.o!(0, disable_always_inline: true)
    @pass_builder.run(@module, @tm)
  end

  def test_inliner_threshold_disable_inline
    @pass_builder.inliner_threshold = 10
    @pass_builder.o!(0, disable_inline: true)
    @pass_builder.run(@module, @tm)
  end

  def test_merge_functions
    @pass_builder.merge_functions = true
    @pass_builder.o!
    @pass_builder.run(@module, @tm)
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

  def test_unknown_pass
    @pass_builder.add_pass('unknown')
    exception = assert_raises(ArgumentError) do
      @pass_builder.run(@module, @tm)
    end
    assert_equal "unknown pass name 'unknown'", exception.message
  end

  def test_msan_kernel_pass
    @pass_builder.msan!(kernel: true)
    assert_equal 'msan<kernel>', @pass_builder.pass_string
    @pass_builder.run(@module, @tm)
  end

  # cannot be run
  def test_dfsan_pass
    @pass_builder.dfsan!
    assert_equal 'dfsan', @pass_builder.pass_string
  end

  # cannot be run
  def test_msan_pass
    @pass_builder.msan!
    assert_equal 'msan', @pass_builder.pass_string
  end

  def test_hypothetical_opt_x_pass
    @pass_builder.o!('x')
    assert_equal 'default<Ox>', @pass_builder.pass_string
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
