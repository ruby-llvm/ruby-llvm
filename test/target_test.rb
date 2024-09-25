# frozen_string_literal: true

require "test_helper"
require 'tempfile'
require 'llvm/version'
require 'llvm/config'

class TargetTestCase < Minitest::Test
  def setup
    LLVM::Target.init('X86', true)
  end

  def test_init_native
    LLVM::Target.init_native
    LLVM::Target.init_native(true)
  end

  def test_init_all
    LLVM::Target.init_all
    LLVM::Target.init_all(true)
  end

  TARGET_CHECKS = {
    'X86' => %w[x86-64 x86],
    'AMDGPU' => %w[amdgcn r600],
    'RISCV' => %w[riscv64 riscv32],
    'WebAssembly' => %w[wasm64 wasm32],
    'PowerPC' => %w[ppc64le ppc64 ppc32le ppc32],
    'LoongArch' => %w[loongarch64 loongarch32],
  }.freeze

  SKIP_ASM_PRINTER = %w[NVPTX XCore].freeze

  LLVM::CONFIG::TARGETS_BUILT.each do |arch|
    define_method(:"test_init_#{arch}") do
      LLVM::Target.init(arch)

      if !SKIP_ASM_PRINTER.include?(arch)
        LLVM::Target.init(arch, true)
      end

      check_targets = TARGET_CHECKS[arch] || [arch.downcase]

      check_targets.each do |target_name|
        assert arch_target = LLVM::Target.by_name(target_name)
        assert_equal target_name, arch_target.name
      end
    end
  end

  def test_each
    targets = LLVM::Target.each

    assert_instance_of Enumerator, targets
    assert_operator targets.count, :>, 0
  end

  def test_target_x86
    assert x86 = LLVM::Target.by_name('x86')
    assert_equal 'x86', x86.name
    assert_equal "32-bit X86: Pentium-Pro and above", x86.description
    assert_predicate x86, :jit?
    assert_predicate x86, :target_machine?
    assert_predicate x86, :asm_backend?
  end

  def test_target_x86_64
    assert x86_64 = LLVM::Target.by_name('x86-64')
    assert_equal 'x86-64', x86_64.name
    assert_equal "64-bit X86: EM64T and AMD64", x86_64.description
    assert_predicate x86_64, :jit?
    assert_predicate x86_64, :target_machine?
    assert_predicate x86_64, :asm_backend?
  end

  def test_target_machine_x86
    assert x86 = LLVM::Target.by_name('x86')
    assert mach = x86.create_machine('x86-linux-gnu', 'i686')

    assert_equal x86, mach.target
    assert_equal 'x86-linux-gnu', mach.triple
    assert_equal 'i686', mach.cpu
    assert_equal '', mach.features
  end

  def test_target_machine_x86_64
    assert x86_64 = LLVM::Target.by_name('x86-64')
    assert mach = x86_64.create_machine('x86_64-pc-linux-gnu', 'i686')

    assert_equal x86_64, mach.target
    assert_equal 'x86_64-pc-linux-gnu', mach.triple
    assert_equal 'i686', mach.cpu
    assert_equal '', mach.features
  end

  def test_emit_x86
    assert x86 = LLVM::Target.by_name('x86')
    assert mach = x86.create_machine('x86-linux-gnu')

    mod = define_module('test') do |mod|
      define_function(mod, 'main', [], LLVM::Int) do |builder, fun|
        entry = fun.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(0))
      end
    end

    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path)
      data = tmp.read
      assert_match(/xorl\t%eax, %eax/, data)
      assert_equal 218, data.length
    end

    # despite the above test, in LLVM <= 11 the objdump output was:
    # 00000000 <main>:
    #    0:   66 31 c0                xor    %ax,%ax
    #    3:   66 c3                   retw
    # In LLVM 13, the objdump output is:
    # 00000000 <main>:
    #    0:   31 c0                   xor    %eax,%eax
    #    2:   c3                      ret
    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path, :object)
      data = File.read(tmp.path, mode: 'rb')
      assert_match(/\x31\xc0\xc3/n, data)
      assert_equal 528, data.length
    end
  end

  def test_emit_x86_64
    assert x86 = LLVM::Target.by_name('x86-64')
    assert mach = x86.create_machine('x86_64-pc-linux-gnu')

    mod = define_module('test') do |mod|
      define_function(mod, 'main', [], LLVM::Int) do |builder, fun|
        entry = fun.basic_blocks.append
        builder.position_at_end(entry)
        builder.ret(LLVM::Int(0))
      end
    end

    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path)
      data = tmp.read
      assert_match(/xorl\t%eax, %eax/, data)
      assert_equal 218, data.length
    end

    Tempfile.open('emit') do |tmp|
      mach.emit(mod, tmp.path, :object)
      data = File.read(tmp.path, mode: 'rb')
      assert_match(/\x31\xc0\xc3/n, data)
      assert_equal 752, data.length
    end
  end

  def test_data_layout
    layout_be = LLVM::TargetDataLayout.new('E')
    assert_equal :big_endian, layout_be.byte_order

    desc = "e-p:32:32:32-S0-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f16:16:16-f32:32:32-f64:64:64-f128:128:128-v64:64:64-v128:128:128-a0:0:64"
    layout = LLVM::TargetDataLayout.new(desc)

    assert_equal desc, layout.to_s
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
