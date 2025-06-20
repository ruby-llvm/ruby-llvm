# frozen_string_literal: true
# typed: true

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
    yielded = false #: bool

    define_module('test_globals_add') do |mod|
      mod.globals.add(LLVM::Int32, 'i') do |var|
        yielded = true

        assert_kind_of LLVM::GlobalVariable, var

        # unnamed_addr
        refute_predicate var, :unnamed_addr?
        var.unnamed_addr = true
        assert_predicate var, :unnamed_addr?

        assert (var.dll_storage_class == :default)
        var.dll_storage_class = :dll_import
        assert (var.dll_storage_class == :dll_import)

        # global_constant
        refute_predicate var, :global_constant?
        var.global_constant = true
        assert_predicate var, :global_constant?

        assert_output("", "Warning: Passing Integer value to LLVM::GlobalValue#global_constant=(Boolean) is deprecated.\n") do
          var.global_constant = 0
        end
        refute_predicate var, :global_constant?
      end
    end

    assert yielded, 'LLVM::Module::GlobalCollection#add takes block'
  end

  def test_to_s
    mod = LLVM::Module.new('test_print')
    assert_equal "; ModuleID = 'test_print'\nsource_filename = \"test_print\"\n",
      mod.to_s
  end

  def test_dump
    mod = LLVM::Module.new('test_print')
    expected_pattern = /^; ModuleID = 'test_print'$/

    Tempfile.create('test_dump.1') do |tmpfile|
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

  def test_module_properties
    mod = LLVM::Module.new('mod')

    assert_equal '', mod.triple

    mod.triple = 'x86-linux-gnu'
    assert_equal 'x86-linux-gnu', mod.triple

    assert_equal '', mod.data_layout

    mod.data_layout = 'e-p:32:32'
    assert_equal 'e-p:32:32', mod.data_layout
  end

  def test_clone
    mod1 = LLVM::Module.new('mod')
    mod1.globals.add(LLVM::Int32, 'a')
    assert_match "@a = external global i32", mod1.to_s
    mod2 = mod1.clone_module
    assert_match "@a = external global i32", mod2.to_s
    mod2.globals.add(LLVM::Int32, 'b')
    assert_match "@b = external global i32", mod2.to_s
    refute_match "@b = external global i32", mod1.to_s
  end

  def test_string_null_terminated
    hello = LLVM::ConstantArray.string("Hello World!")
    mod1 = LLVM::Module.new('mod')
    mod1.globals.add(hello, 'hello') do |var|
      var.initializer = hello
    end
    assert_match '@hello = global [13 x i8] c"Hello World!\\00"', mod1.to_s
  end

  def test_string
    hello = LLVM::ConstantArray.string("Hello World!", false)
    mod1 = LLVM::Module.new('mod')
    mod1.globals.add(hello, 'hello') do |var|
      var.initializer = hello
    end
    assert_match '@hello = global [12 x i8] c"Hello World!"', mod1.to_s
  end

  def test_string_in_context
    context = LLVM::Context.new
    hello = LLVM::ConstantArray.string_in_context(context, "Hello World!", false)
    mod1 = LLVM::Module.new('mod')
    mod1.globals.add(hello, 'hello') do |var|
      var.initializer = hello
    end
    assert_match '@hello = global [12 x i8] c"Hello World!"', mod1.to_s
  end

  def test_global_var
    context = LLVM::Context.new
    hello = LLVM::ConstantArray.string_in_context(context, "Hello World!", false)
    mod1 = LLVM::Module.new('mod')
    global_var = mod1.globals.add(hello, 'hello') do |var|
      var.initializer = hello
    end

    assert_kind_of LLVM::GlobalValue, global_var
    assert_kind_of LLVM::GlobalVariable, global_var

    assert_nil global_var.section

    assert_equal :external, global_var.linkage
    assert_equal :default, global_var.visibility
    assert_equal 0, global_var.alignment
    assert_equal '[12 x i8] c"Hello World!"', global_var.initializer.to_s
    assert_equal :default, global_var.dll_storage_class

    assert_predicate global_var, :declaration?
    refute_predicate global_var, :unnamed_addr?
    refute_predicate global_var, :thread_local?
    refute_predicate global_var, :global_constant?
    assert_predicate global_var, :externally_initialized?
  end
end
