# frozen_string_literal: true

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
end
