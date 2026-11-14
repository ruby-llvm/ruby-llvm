# frozen_string_literal: true
# typed: true

require 'test_helper'
require 'llvm/core'
require 'llvm/linker'

class LinkerTestCase < Minitest::Test
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

  # LLVMLinkModules2 destroys the source module, so its pointer must not be
  # used or disposed of again
  def test_link_into_clears_source_module_pointer
    create_modules
    @mod2.link_into(@mod1)

    assert_nil @mod2.to_ptr
  end
end
