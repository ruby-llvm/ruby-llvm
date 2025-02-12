# frozen_string_literal: true

require "test_helper"

class BuilderGepTestCase < Minitest::Test # rubocop:disable Metrics/ClassLength
  private

  attr_reader :mod, :fun

  public

  def setup
    @mod = LLVM::Module.new("BuilderTestCase")
    @fun = mod.functions.add("test_builder", [LLVM.ptr], LLVM.Void) do |f|
      f.basic_blocks.append
    end
  end

  # gep can get type from alloca
  def test_gep_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.gep(alloca, LLVM.i(64, 0))
      float = b.gep(alloca, LLVM.i(64, 1))
      int_named = b.gep(alloca, LLVM.i(64, 0), "the_int")
      float_named = b.gep(alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr { i64, double }, ptr %2, i64 0
        %4 = getelementptr { i64, double }, ptr %2, i64 1
        %the_int = getelementptr { i64, double }, ptr %2, i64 0
        %the_float = getelementptr { i64, double }, ptr %2, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_gep2_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.gep2(type, alloca, LLVM.i(64, 0))
      float = b.gep2(type, alloca, LLVM.i(64, 1))
      int_named = b.gep2(type, alloca, LLVM.i(64, 0), "the_int")
      float_named = b.gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr { i64, double }, ptr %2, i64 0
        %4 = getelementptr { i64, double }, ptr %2, i64 1
        %the_int = getelementptr { i64, double }, ptr %2, i64 0
        %the_float = getelementptr { i64, double }, ptr %2, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_inbounds_gep_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.inbounds_gep(alloca, LLVM.i(64, 0))
      float = b.inbounds_gep(alloca, LLVM.i(64, 1))
      int_named = b.inbounds_gep(alloca, LLVM.i(64, 0), "the_int")
      float_named = b.inbounds_gep(alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr inbounds { i64, double }, ptr %2, i64 0
        %4 = getelementptr inbounds { i64, double }, ptr %2, i64 1
        %the_int = getelementptr inbounds { i64, double }, ptr %2, i64 0
        %the_float = getelementptr inbounds { i64, double }, ptr %2, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_inbounds_gep2_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.inbounds_gep2(type, alloca, LLVM.i(64, 0))
      float = b.inbounds_gep2(type, alloca, LLVM.i(64, 1))
      int_named = b.inbounds_gep2(type, alloca, LLVM.i(64, 0), "the_int")
      float_named = b.inbounds_gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr inbounds { i64, double }, ptr %2, i64 0
        %4 = getelementptr inbounds { i64, double }, ptr %2, i64 1
        %the_int = getelementptr inbounds { i64, double }, ptr %2, i64 0
        %the_float = getelementptr inbounds { i64, double }, ptr %2, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_struct_gep_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.struct_gep2(type, alloca, 0)
      float = b.struct_gep2(type, alloca, 1.5)
      int_named = b.struct_gep2(type, alloca, "0", "the_int")
      float_named = b.struct_gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 0
        %4 = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 1
        %the_int = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 0
        %the_float = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_struct_gep2_of_alloca
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = b.alloca(type)
      int = b.struct_gep2(type, alloca, 0)
      float = b.struct_gep2(type, alloca, 1.5)
      int_named = b.struct_gep2(type, alloca, "0", "the_int")
      float_named = b.struct_gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_equal type, alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca { i64, double }, align 8
        %3 = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 0
        %4 = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 1
        %the_int = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 0
        %the_float = getelementptr inbounds nuw { i64, double }, ptr %2, i32 0, i32 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_gep_of_ptr
    bb = fun.basic_blocks.first
    bb.build do |b|
      alloca = fun.params.first
      assert_raises(ArgumentError) do
        b.gep(alloca, LLVM.i(64, 0))
      end
    end
  end

  def test_gep2_of_ptr
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = fun.params.first
      int = b.gep2(type, alloca, LLVM.i(64, 0))
      float = b.gep2(type, alloca, LLVM.i(64, 1))
      int_named = b.gep2(type, alloca, LLVM.i(64, 0), "the_int")
      float_named = b.gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_nil alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = getelementptr { i64, double }, ptr %0, i64 0
        %3 = getelementptr { i64, double }, ptr %0, i64 1
        %the_int = getelementptr { i64, double }, ptr %0, i64 0
        %the_float = getelementptr { i64, double }, ptr %0, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_inbounds_gep_of_ptr
    bb = fun.basic_blocks.first
    bb.build do |b|
      alloca = fun.params.first
      assert_raises(ArgumentError) do
        b.inbounds_gep(alloca, LLVM.i(64, 0))
      end
    end
  end

  def test_inbounds_gep2_of_ptr
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = fun.params.first
      int = b.inbounds_gep2(type, alloca, LLVM.i(64, 0))
      float = b.inbounds_gep2(type, alloca, LLVM.i(64, 1))
      int_named = b.inbounds_gep2(type, alloca, LLVM.i(64, 0), "the_int")
      float_named = b.inbounds_gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_nil alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = getelementptr inbounds { i64, double }, ptr %0, i64 0
        %3 = getelementptr inbounds { i64, double }, ptr %0, i64 1
        %the_int = getelementptr inbounds { i64, double }, ptr %0, i64 0
        %the_float = getelementptr inbounds { i64, double }, ptr %0, i64 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end

  def test_struct_gep_of_ptr
    bb = fun.basic_blocks.first
    bb.build do |b|
      alloca = fun.params.first
      assert_raises(ArgumentError) do
        b.struct_gep(alloca, LLVM.i(64, 0))
      end
    end
  end

  def test_struct_gep2_of_ptr
    bb = fun.basic_blocks.first
    type = LLVM::Struct(LLVM.i(64), LLVM.double)
    bb.build do |b|
      alloca = fun.params.first
      int = b.struct_gep2(type, alloca, 0)
      float = b.struct_gep2(type, alloca, 1.5)
      int_named = b.struct_gep2(type, alloca, "0", "the_int")
      float_named = b.struct_gep2(type, alloca, LLVM.i(64, 1), "the_float")

      assert_nil alloca.allocated_type
      assert_equal type, int.allocated_type
      assert_equal type, float.allocated_type
      assert_equal type, int_named.allocated_type
      assert_equal type, float_named.allocated_type
      assert_equal type, int.gep_source_element_type
      assert_equal type, float.gep_source_element_type
      assert_equal type, int_named.gep_source_element_type
      assert_equal type, float_named.gep_source_element_type

      b.ret
    end
    assert(fun.verify)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = getelementptr inbounds nuw { i64, double }, ptr %0, i32 0, i32 0
        %3 = getelementptr inbounds nuw { i64, double }, ptr %0, i32 0, i32 1
        %the_int = getelementptr inbounds nuw { i64, double }, ptr %0, i32 0, i32 0
        %the_float = getelementptr inbounds nuw { i64, double }, ptr %0, i32 0, i32 1
        ret void
      }
    IR
    assert_equal(expected, fun.to_s)
  end
end
