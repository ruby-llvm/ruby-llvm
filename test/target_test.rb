# encoding: ascii-8bit

require "test_helper"
require 'tempfile'
require 'llvm/version'
require 'llvm/config'

class TargetTestCase < Minitest::Test

  def setup
    LLVM::Target.init('X86', true)

    @x86 = LLVM::Target.by_name('x86')
  end

  def test_init_native
    LLVM::Target.init_native
    LLVM::Target.init_native(true)
  end

  if LLVM::CONFIG::TARGETS_BUILT.include?('ARM')
    def test_init_arm
      LLVM::Target.init('ARM')
      LLVM::Target.init('ARM', true)

      arm_target = LLVM::Target.by_name('arm')
      assert_equal 'arm', arm_target.name
    end
  end

  def test_init_all
    LLVM::Target.init_all
    LLVM::Target.init_all(true)
  end

  def test_each
    targets = LLVM::Target.each

    assert_instance_of Enumerator, targets
    assert targets.count > 0
  end

  def test_target
    assert_equal 'x86', @x86.name
    assert_equal "32-bit X86: Pentium-Pro and above", @x86.description
    assert_equal true, @x86.jit?
    assert_equal true, @x86.target_machine?
    assert_equal true, @x86.asm_backend?
  end

  def test_target_machine
    @x86 = LLVM::Target.by_name('x86')
    mach = @x86.create_machine('x86-linux-gnu', 'i686')

    assert_equal @x86, mach.target
    assert_equal 'x86-linux-gnu', mach.triple
    assert_equal 'i686', mach.cpu
    assert_equal '', mach.features

    layout = mach.data_layout
    assert_equal 'e-m:e-p:32:32-f64:32:64-f80:32-n8:16:32-S128', layout.to_s
  end

  def test_emit
    mach = @x86.create_machine('x86-linux-gnu')

    mod = define_module('test') do |mod|
      define_function(mod, 'main', [], LLVM::Int) do |builder, fun|
        entry = fun.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(0))
      end
    end

    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path)
      assert_match %r{xorl\t%eax, %eax}, tmp.read
    end

    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path, :object)
      assert_match %r{\x66\x31\xc0}, File.read(tmp.path, mode: 'rb')
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

  def test_data_layout
    layout_be = LLVM::TargetDataLayout.new('E')
    assert_equal :big_endian, layout_be.byte_order

    desc = "e-p:32:32:32-S0-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f16:16:16-f32:32:32-f64:64:64-f128:128:128-v64:64:64-v128:128:128-a0:0:64"
    layout = LLVM::TargetDataLayout.new(desc)

    assert_equal "e-p:32:32", layout.to_s
    assert_equal :little_endian, layout.byte_order
    assert_equal 4, layout.pointer_size
    assert_equal 4, layout.pointer_size(0)
    assert_equal LLVM::Int32.type, layout.int_ptr_type
    assert_equal LLVM::Int32.type, layout.int_ptr_type(0)

    assert_equal 19, layout.bit_size_of(LLVM::Int19.type)
    assert_equal 3, layout.storage_size_of(LLVM::Int19.type)
    assert_equal 4, layout.abi_size_of(LLVM::Int19.type)
    assert_equal 4, layout.abi_alignment_of(LLVM::Int19.type)
    assert_equal 4, layout.call_frame_alignment_of(LLVM::Int19.type)
    assert_equal 4, layout.preferred_alignment_of(LLVM::Int19.type)

    struct = LLVM.Struct(LLVM::Int8, LLVM::Int32)

    assert_equal 0, layout.offset_of_element(struct, 0)
    assert_equal 4, layout.offset_of_element(struct, 1)

    assert_equal 0, layout.element_at_offset(struct, 0)
    assert_equal 0, layout.element_at_offset(struct, 3)
    assert_equal 1, layout.element_at_offset(struct, 4)
  end
end
