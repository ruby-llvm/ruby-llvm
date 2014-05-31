require "test_helper"
require "tempfile"

class ModuleTestCase < Minitest::Test

  def setup
    LLVM.init_jit
  end

  def simple_function
    run_function([], [], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      builder.ret(LLVM::Int(1))
    end
  end

  def test_simple_module
    assert_equal 1, simple_function().to_i
  end

  def test_global_variable
    yielded = false

    define_module('test_globals_add') do |mod|
      mod.globals.add(LLVM::Int32, 'i') do |var|
        yielded = true

        assert var.kind_of?(LLVM::GlobalVariable)

        # unnamed_addr
        assert !var.unnamed_addr?
        var.unnamed_addr = true
        assert var.unnamed_addr?

        # global_constant
        assert !var.global_constant?
        var.global_constant = true
        assert var.global_constant?

        assert_output("", "Warning: Passing Integer value to LLVM::GlobalValue#global_constant=(Boolean) is deprecated.\n") do
          var.global_constant = 0
        end
      end
    end

    assert yielded, 'LLVM::Module::GlobalCollection#add takes block'
  end

  def test_to_s
    mod = LLVM::Module.new('test_print')
    assert_equal mod.to_s, "; ModuleID = 'test_print'\n"
  end

  def test_dump
    mod = LLVM::Module.new('test_print')
    expected_pattern = /^; ModuleID = 'test_print'$/

    Tempfile.open('test_dump.1') do |tmpfile|
      # debug stream (stderr)
      stderr_old = $stderr.dup
      $stderr.reopen(tmpfile.path, 'a')
      begin
        mod.dump
        $stderr.flush
        assert_match expected_pattern, File.read(tmpfile.path)
      ensure
        $stderr.reopen(stderr_old)
      end
    end
  end

end
