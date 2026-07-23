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

  def test_global_variable_initializer_kind
    define_module('test_initializer_kind') do |mod|
      mod.globals.add(LLVM::Int32, 'off') do |var|
        var.initializer = LLVM::Int32.from_i(42)
        var.global_constant = true
      end
      init = mod.globals['off'].initializer
      assert_kind_of LLVM::ConstantInt, init
      assert_equal 42, init.to_i(false)
    end
  end

  def test_from_ptr_kind_const_data_array
    define_module('test_fpk_cda') do |mod|
      arr = LLVM::ConstantArray.string('hi')
      mod.globals.add(arr, 'str') do |var|
        var.initializer = arr
        var.global_constant = true
      end
      init = mod.globals['str'].initializer
      assert_equal :const_data_array, init.kind
      assert_kind_of LLVM::ConstantArray, init
    end
  end

  def test_from_ptr_kind_const_array
    define_module('test_fpk_ca') do |mod|
      struct_type = LLVM::Struct(LLVM::Int32)
      elem = LLVM::ConstantStruct.const([LLVM::Int32.from_i(1)])
      arr = LLVM::ConstantArray.const(struct_type, [elem])
      mod.globals.add(arr, 'sarr') do |var|
        var.initializer = arr
        var.global_constant = true
      end
      init = mod.globals['sarr'].initializer
      assert_equal :const_array, init.kind
      assert_kind_of LLVM::ConstantArray, init
    end
  end

  def test_from_ptr_kind_const_data_vector
    define_module('test_fpk_cdv') do |mod|
      vec = LLVM::ConstantVector.const([LLVM::Int32.from_i(1), LLVM::Int32.from_i(2)])
      mod.globals.add(vec, 'vec') do |var|
        var.initializer = vec
        var.global_constant = true
      end
      init = mod.globals['vec'].initializer
      assert_equal :const_data_vector, init.kind
      assert_kind_of LLVM::ConstantVector, init
    end
  end

  def test_from_ptr_kind_const_aggregate_zero
    define_module('test_fpk_caz') do |mod|
      zero = LLVM::ConstantStruct.const([LLVM::Int32.from_i(0)])
      mod.globals.add(zero, 'zs') do |var|
        var.initializer = zero
        var.global_constant = true
      end
      init = mod.globals['zs'].initializer
      assert_equal :const_aggregate_zero, init.kind
      assert_kind_of LLVM::ConstantStruct, init
    end
  end

  def test_to_s
    mod = LLVM::Module.new('test_print')
    assert_equal "; ModuleID = 'test_print'\nsource_filename = \"test_print\"\n",
      mod.to_s
  end

  def test_dump
    mod = LLVM::Module.new('test_print')

    if RUBY_PLATFORM.include?('mswin')
      # Output goes to the extension DLL's CRT fd table, not Ruby's, so pipe
      # redirection cannot capture it. Just verify the call doesn't crash.
      mod.dump
      skip 'Cannot capture dump output on mswin: CRT fd table isolation'
    end

    rd, wr = IO.pipe
    begin
      stderr_old = $stderr.dup
      $stderr.reopen(wr)
      wr.close
      begin
        mod.dump
        $stderr.flush
      ensure
        $stderr.reopen(stderr_old)
        stderr_old.close
      end
      assert_match(/^; ModuleID = 'test_print'$/, rd.read)
    ensure
      rd.close
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
