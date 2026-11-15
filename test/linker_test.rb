# frozen_string_literal: true
# typed: true

require 'test_helper'
require 'open3'
require 'llvm/core'
require 'llvm/linker'

class LinkerTestCase < Minitest::Test
  LIB = File.expand_path("../lib", __dir__)

  # Links two modules that both define calc, so the link fails, and prints
  # what link_into returned.
  FAILING_LINK = <<~RUBY
    require "llvm/core"
    require "llvm/linker"

    def module_defining_calc(name)
      LLVM::Module.new(name).tap do |mod|
        mod.functions.add("calc", [], LLVM::Int32) do |fn|
          fn.basic_blocks.append.build { |builder| builder.ret LLVM::Int32.from_i(1) }
        end
      end
    end

    dest = module_defining_calc("dest")
    print module_defining_calc("src").link_into(dest).inspect
  RUBY

  def setup
    LLVM.init_jit
  end

  def create_modules
    @mod1 = define_module('mod1') do |mod|
      mod1calc = mod.functions.add("calc", [], LLVM::Int32)

      mod.functions.add("main", [], LLVM::Int32) do |fn|
        fn.basic_blocks.append.build do |builder|
          val = builder.call(mod1calc)
          builder.ret val
        end
      end
    end

    @mod2 = define_module('mod2') do |mod|
      mod.functions.add("calc", [], LLVM::Int32) do |fn|
        fn.basic_blocks.append.build do |builder|
          builder.ret LLVM::Int32.from_i(42)
        end
      end
    end
  end

  def test_link_into
    create_modules
    @mod2.link_into(@mod1)

    assert_equal 42, run_function_on_module(@mod1, 'main').to_i
  end

  # true on success, so `if mod.link_into(other)` reads naturally; this is the
  # inverse of LLVMLinkModules2, which returns true if an error occurred
  def test_link_into_returns_true_on_success
    create_modules

    assert_same true, @mod2.link_into(@mod1)
  end

  # Without a diagnostic handler, LLVM prints a link error and exits the
  # process, so the link runs in a child process: a regression fails this test
  # instead of ending the test run.
  def test_link_into_returns_false_on_failure
    skip "a failed link ends the process until link_into installs a diagnostic handler: " \
         "https://github.com/ruby-llvm/ruby-llvm/issues/346"

    stdout, stderr, status = Open3.capture3(Gem.ruby, "-I", LIB, "-e", FAILING_LINK)

    assert_predicate status, :success?, stderr
    assert_equal "false", stdout
  end

  # LLVMLinkModules2 destroys the source module, so its pointer must not be
  # used or disposed of again
  def test_link_into_clears_source_module_pointer
    create_modules
    @mod2.link_into(@mod1)

    assert_nil @mod2.to_ptr
  end
end
