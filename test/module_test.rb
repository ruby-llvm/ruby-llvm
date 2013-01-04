require "test_helper"
require "tempfile"

class ModuleTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_simple_module
    assert_equal 1, simple_function().to_i
  end

  def simple_function
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(LLVM::Int(1))
    end
  end

  def test_global_variable
    yielded = false

    define_module('test_globals_add') do |mod|
      mod.globals.add(LLVM::Int32, 'i') do |var|
        yielded = true
        assert_not_nil var
        assert var.kind_of?(LLVM::GlobalVariable)

        assert !var.unnamed_addr?
        var.unnamed_addr = true
        assert var.unnamed_addr?
      end
    end

    assert yielded, 'LLVM::Module::GlobalCollection#add takes block'
  end

  def test_print
    f1 = Tempfile.new('test_print.1')
    f2 = Tempfile.new('test_print.2')

    begin
      mod = LLVM::Module.new('test_print')
      expected_pattern = /^; ModuleID = 'test_print'$/

      # file descriptor
      mod.print(f1.fileno)
      assert_match expected_pattern, File.read(f1.path)

      # io object
      mod.print(f2)
      assert_match expected_pattern, File.read(f2.path)
    ensure
      f1.close(true)
      f2.close(true)
    end
  end

end
