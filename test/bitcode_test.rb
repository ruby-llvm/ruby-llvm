require "test_helper"
require "tempfile"

class BitcodeTestCase < Test::Unit::TestCase
  def setup
    LLVM.init_jit
  end

  def test_bitcode
    test_module = define_module("test_module") do |mod|
      define_function(mod, "test_function", [], LLVM::Int) do
        |builder, function, *arguments|
        entry = function.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(1))
      end
    end
    Tempfile.open("bitcode") do |tmp|
      assert test_module.write_bitcode(tmp)
      new_module = LLVM::Module.parse_bitcode(tmp.path)
      result = run_function_on_module(new_module, "test_function").to_i
      assert_equal 1, result
    end
  end
end
