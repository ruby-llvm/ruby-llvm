# frozen_string_literal: true

require "test_helper"

class BuilderTestCase < Minitest::Test # rubocop:disable Metrics/ClassLength
  private

  attr_reader :mod, :fun

  def assert_function_ir(expected, fun)
    assert_equal(expected, fun.to_s)
    assert(fun.verify)
    assert_predicate(fun, :valid?)
  end

  public

  def setup
    @mod = LLVM::Module.new("BuilderTestCase")
    @fun = mod.functions.add("test_builder", [LLVM.ptr], LLVM.Void) do |f|
      f.basic_blocks.append
    end
  end

  # gep can get type from alloca
  def test_null_tests
    bb = fun.basic_blocks.first
    param = fun.params.first

    bb.build do |b|
      b.is_null(param)
      b.is_null(param, "named1")
      b.is_not_null(param)
      b.is_not_null(param, "named2")
      b.ret
    end

    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = icmp eq ptr %0, null
        %named1 = icmp eq ptr %0, null
        %3 = icmp ne ptr %0, null
        %named2 = icmp ne ptr %0, null
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_unwind
    bb = fun.basic_blocks.first
    bb.build do |b|
      assert_raises(LLVM::DeprecationError) do
        b.unwind
      end
    end
  end

  def test_unreachable
    bb = fun.basic_blocks.first
    bb.build(&:unreachable)
    expected = <<~IR
      define void @test_builder(ptr %0) {
        unreachable
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_int_instructions
    bb = fun.basic_blocks.first
    param = fun.params.first
    bb.build do |b|
      load = b.load2(LLVM.i(32), param)
      b.neg(load)
      b.neg(load, 'neg')
      b.nsw_neg(load)
      b.nsw_neg(load, 'nsw_neg')
      b.nuw_neg(load)
      b.nuw_neg(load, 'nuw_neg')
      b.not(load)
      b.not(load, 'not')
      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load i32, ptr %0, align 4
        %3 = sub i32 0, %2
        %neg = sub i32 0, %2
        %4 = sub nsw i32 0, %2
        %nsw_neg = sub nsw i32 0, %2
        %5 = sub nuw i32 0, %2
        %nuw_neg = sub nuw i32 0, %2
        %6 = xor i32 %2, -1
        %not = xor i32 %2, -1
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_int_instructions_with_flag_setters
    bb = fun.basic_blocks.first
    param = fun.params.first
    bb.build do |b|
      load = b.load2(LLVM.i(32), param)
      b.neg(load)
      b.neg(load, 'neg')
      b.neg(load).nsw!
      b.neg(load, 'nsw_neg').nsw!
      b.neg(load).nuw!
      b.neg(load, 'nuw_neg').nuw!
      b.not(load)
      b.not(load, 'not')
      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load i32, ptr %0, align 4
        %3 = sub i32 0, %2
        %neg = sub i32 0, %2
        %4 = sub nsw i32 0, %2
        %nsw_neg = sub nsw i32 0, %2
        %5 = sub nuw i32 0, %2
        %nuw_neg = sub nuw i32 0, %2
        %6 = xor i32 %2, -1
        %not = xor i32 %2, -1
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_trunct_with_flag_setters
    bb = fun.basic_blocks.first
    param = fun.params.first
    bb.build do |b|
      load = b.load2(LLVM.i(32), param)
      b.trunc(load, LLVM.i(16))
      b.trunc(load, LLVM.i(16), 'trunc')
      b.trunc(load, LLVM.i(16)).nsw!
      b.trunc(load, LLVM.i(16), 'trunc_nsw').nsw!
      b.trunc(load, LLVM.i(16)).nuw!
      b.trunc(load, LLVM.i(16), 'trunc_nuw').nuw!
      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load i32, ptr %0, align 4
        %3 = trunc i32 %2 to i16
        %trunc = trunc i32 %2 to i16
        %4 = trunc nsw i32 %2 to i16
        %trunc_nsw = trunc nsw i32 %2 to i16
        %5 = trunc nuw i32 %2 to i16
        %trunc_nuw = trunc nuw i32 %2 to i16
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_malloc_free # rubocop:disable Metrics/MethodLength
    bb = fun.basic_blocks.first
    type = LLVM.i(64)
    bb.build do |b|
      malloc1 = b.malloc(type)
      malloc2 = b.malloc(type, 'malloc')
      array1 = b.array_malloc(type, LLVM.i(32, 128))
      array2 = b.array_malloc(type, LLVM.i(32, 128), 'array_malloc1')
      array3 = b.array_malloc(type, 128)
      array4 = b.array_malloc(type, 128, 'array_malloc2')
      b.free(malloc1)
      b.free(malloc2)
      b.free(array1)
      b.free(array2)
      b.free(array3)
      b.free(array4)

      assert_raises(ArgumentError) do
        b.array_malloc(type, "foo")
      end

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32))
        %malloc = tail call ptr @malloc(i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32))
        %3 = tail call ptr @malloc(i32 mul (i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32), i32 128))
        %array_malloc1 = tail call ptr @malloc(i32 mul (i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32), i32 128))
        %4 = tail call ptr @malloc(i32 mul (i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32), i32 128))
        %array_malloc2 = tail call ptr @malloc(i32 mul (i32 ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i32), i32 128))
        tail call void @free(ptr %2)
        tail call void @free(ptr %malloc)
        tail call void @free(ptr %3)
        tail call void @free(ptr %array_malloc1)
        tail call void @free(ptr %4)
        tail call void @free(ptr %array_malloc2)
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_pointer_cast
    bb = fun.basic_blocks.first
    param = fun.params.first

    type = LLVM.i(64)
    bb.build do |b|
      ptr2int = b.ptr2int(param, type)
      ptr2int2 = b.ptr2int(param, type, 'ptr2int')
      b.int2ptr(ptr2int, LLVM.ptr)
      b.int2ptr(ptr2int2, LLVM.ptr, 'int2ptr')

      b.pointer_cast(param, type)
      b.pointer_cast(param, type, 'pointer_cast')

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = ptrtoint ptr %0 to i64
        %ptr2int = ptrtoint ptr %0 to i64
        %3 = inttoptr i64 %2 to ptr
        %int2ptr = inttoptr i64 %ptr2int to ptr
        %4 = ptrtoint ptr %0 to i64
        %pointer_cast = ptrtoint ptr %0 to i64
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_fp_cast
    bb = fun.basic_blocks.first
    param = fun.params.first

    type = LLVM.float
    bb.build do |b|
      double = b.load2(type, param)

      b.fp_cast(double, LLVM::Type.from_ptr(LLVM::C.half_type))
      b.fp_cast(double, LLVM.float)
      b.fp_cast(double, LLVM.double)

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load float, ptr %0, align 4
        %3 = fptrunc float %2 to half
        %4 = fpext float %2 to double
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_int_cast
    bb = fun.basic_blocks.first
    param = fun.params.first

    type = LLVM.i(32)
    bb.build do |b|
      int = b.load2(type, param)

      b.int_cast(int, LLVM.i(16))
      b.int_cast(int, LLVM.i(32))
      b.int_cast(int, LLVM.i(64))

      b.int_cast(int, LLVM.i(16), 'cast16')
      b.int_cast(int, LLVM.i(32), 'cast32')
      b.int_cast(int, LLVM.i(64), 'cast64')

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load i32, ptr %0, align 4
        %3 = trunc i32 %2 to i16
        %4 = sext i32 %2 to i64
        %cast16 = trunc i32 %2 to i16
        %cast64 = sext i32 %2 to i64
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_int_cast2 # rubocop:disable Metrics/MethodLength
    bb = fun.basic_blocks.first
    param = fun.params.first

    type = LLVM.i(32)
    bb.build do |b|
      int = b.load2(type, param)

      b.int_cast2(int, LLVM.i(16), true)
      b.int_cast2(int, LLVM.i(32), true)
      b.int_cast2(int, LLVM.i(64), true)

      b.int_cast2(int, LLVM.i(16), false)
      b.int_cast2(int, LLVM.i(32), false)
      b.int_cast2(int, LLVM.i(64), false)

      b.int_cast2(int, LLVM.i(16), true, 'trunc-signed')
      b.int_cast2(int, LLVM.i(32), true, 'nada')
      b.int_cast2(int, LLVM.i(64), true, 'sext64')

      b.int_cast2(int, LLVM.i(16), false, 'trunc-unsigned')
      b.int_cast2(int, LLVM.i(32), false, 'nada')
      b.int_cast2(int, LLVM.i(64), false, 'zext64')

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = load i32, ptr %0, align 4
        %3 = trunc i32 %2 to i16
        %4 = sext i32 %2 to i64
        %5 = trunc i32 %2 to i16
        %6 = zext i32 %2 to i64
        %trunc-signed = trunc i32 %2 to i16
        %sext64 = sext i32 %2 to i64
        %trunc-unsigned = trunc i32 %2 to i16
        %zext64 = zext i32 %2 to i64
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  # test global_string
  # test global_string_ptr
  def test_global_string
    bb = fun.basic_blocks.first
    bb.build do |b|
      hello = b.global_string("HELLO")
      world = b.global_string("WORLD", 'world1')
      hello_ptr = b.global_string_pointer("HELLO")
      world_ptr = b.global_string_pointer("WORLD", 'world2')

      assert_kind_of LLVM::GlobalVariable, hello
      assert_kind_of LLVM::GlobalVariable, world
      assert_kind_of LLVM::GlobalVariable, hello_ptr
      assert_kind_of LLVM::GlobalVariable, world_ptr

      assert_equal "@0 = private unnamed_addr constant [6 x i8] c\"HELLO\\00\", align 1", hello.to_s
      assert_equal "@1 = private unnamed_addr constant [6 x i8] c\"HELLO\\00\", align 1", hello_ptr.to_s

      assert_equal "@world1 = private unnamed_addr constant [6 x i8] c\"WORLD\\00\", align 1", world.to_s
      assert_equal "@world2 = private unnamed_addr constant [6 x i8] c\"WORLD\\00\", align 1", world_ptr.to_s
      b.ret
    end
    expected = <<~IR
      ; ModuleID = 'BuilderTestCase'
      source_filename = "BuilderTestCase"

      @0 = private unnamed_addr constant [6 x i8] c"HELLO\\00", align 1
      @world1 = private unnamed_addr constant [6 x i8] c"WORLD\\00", align 1
      @1 = private unnamed_addr constant [6 x i8] c"HELLO\\00", align 1
      @world2 = private unnamed_addr constant [6 x i8] c"WORLD\\00", align 1

      define void @test_builder(ptr %0) {
        ret void
      }
    IR
    assert_equal(expected, mod.to_s)
    assert_predicate(fun, :valid?)
    assert_predicate(mod, :valid?)
  end

  def test_int_casts
    bb = fun.basic_blocks.first
    bb.build do |b|
      int = b.load(b.alloca(LLVM.i(64)))

      b.zext_or_bit_cast(int, LLVM.i(64))
      b.zext_or_bit_cast(int, LLVM.i(128))
      b.zext_or_bit_cast(int, LLVM.double)

      b.sext_or_bit_cast(int, LLVM.i(64))
      b.sext_or_bit_cast(int, LLVM.i(128))
      b.sext_or_bit_cast(int, LLVM.double)

      b.trunc_or_bit_cast(int, LLVM.i(64))
      b.trunc_or_bit_cast(int, LLVM.i(32))
      b.trunc_or_bit_cast(int, LLVM.double)

      b.ret
    end
    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca i64, align 8
        %3 = load i64, ptr %2, align 4
        %4 = zext i64 %3 to i128
        %5 = bitcast i64 %3 to double
        %6 = sext i64 %3 to i128
        %7 = bitcast i64 %3 to double
        %8 = trunc i64 %3 to i32
        %9 = bitcast i64 %3 to double
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_ptr_diff_of_ptrs
    bb = fun.basic_blocks.first
    param = fun.params.first

    bb.build do |b|
      assert_raises(ArgumentError) do
        b.ptr_diff(param, param)
      end
    end
  end

  def test_ptr_diff2_of_ptrs
    bb = fun.basic_blocks.first
    param = fun.params.first
    type = LLVM.i(64)

    bb.build do |b|
      b.ptr_diff2(type, param, param)
      b.ptr_diff2(type, param, param, 'named')
      b.ret
    end

    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = ptrtoint ptr %0 to i64
        %3 = ptrtoint ptr %0 to i64
        %4 = sub i64 %2, %3
        %5 = sdiv exact i64 %4, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        %6 = ptrtoint ptr %0 to i64
        %7 = ptrtoint ptr %0 to i64
        %8 = sub i64 %6, %7
        %named = sdiv exact i64 %8, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_ptr_diff_of_allocas
    bb = fun.basic_blocks.first
    type = LLVM.i(64)

    bb.build do |b|
      alloca1 = b.alloca(type)
      alloca2 = b.alloca(type)
      b.ptr_diff(alloca1, alloca2)
      b.ptr_diff(alloca1, alloca2, 'named')
      b.ret
    end

    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca i64, align 8
        %3 = alloca i64, align 8
        %4 = ptrtoint ptr %2 to i64
        %5 = ptrtoint ptr %3 to i64
        %6 = sub i64 %4, %5
        %7 = sdiv exact i64 %6, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        %8 = ptrtoint ptr %2 to i64
        %9 = ptrtoint ptr %3 to i64
        %10 = sub i64 %8, %9
        %named = sdiv exact i64 %10, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end

  def test_ptr_diff2_of_allocas
    bb = fun.basic_blocks.first
    type = LLVM.i(64)

    bb.build do |b|
      alloca1 = b.alloca(type)
      alloca2 = b.alloca(type)
      b.ptr_diff2(type, alloca1, alloca2)
      b.ptr_diff2(type, alloca1, alloca2, 'named')
      b.ret
    end

    expected = <<~IR
      define void @test_builder(ptr %0) {
        %2 = alloca i64, align 8
        %3 = alloca i64, align 8
        %4 = ptrtoint ptr %2 to i64
        %5 = ptrtoint ptr %3 to i64
        %6 = sub i64 %4, %5
        %7 = sdiv exact i64 %6, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        %8 = ptrtoint ptr %2 to i64
        %9 = ptrtoint ptr %3 to i64
        %10 = sub i64 %8, %9
        %named = sdiv exact i64 %10, ptrtoint (ptr getelementptr (i64, ptr null, i32 1) to i64)
        ret void
      }
    IR
    assert_function_ir(expected, fun)
  end
end
