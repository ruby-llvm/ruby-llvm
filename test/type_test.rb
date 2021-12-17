require "test_helper"

class TypeTestCase < Minitest::Test

  extend MiniTest::Spec::DSL

  def test_element_type
    pointer = LLVM.Pointer(LLVM::Int32.type)
    pointee = pointer.element_type

    assert_equal :pointer, pointer.kind
    assert_equal :integer, pointee.kind

    assert_nil pointee.element_type
  end

  TO_S_TESTS = [
    [LLVM.Struct(LLVM::Int32, LLVM::Int32), '{ i32, i32 }'],
    [LLVM.Struct(LLVM::Int32, LLVM::Int32, "s1"), '%s1 = type { i32, i32 }'],
    [LLVM::Type.struct([LLVM::Int32, LLVM::Int32], true), '<{ i32, i32 }>'],
    [LLVM::Type.struct([LLVM::Int32, LLVM::Int32], true, "s2"), '%s2 = type <{ i32, i32 }>'],

    [LLVM.Array(LLVM::Int8), '[0 x i8]'],
    [LLVM.Array(LLVM::Int8, 42), '[42 x i8]'],
    [LLVM::Type.array(LLVM::Int1), '[0 x i1]'],
    [LLVM::Type.array(LLVM::Int1, 42), '[42 x i1]'],

    [LLVM.Vector(LLVM::Int8, 42), '<42 x i8>'],
    [LLVM::Type.vector(LLVM::Int1, 42), '<42 x i1>'],

    [LLVM.Void, 'void'],
    [LLVM::Type.void, 'void'],

    [LLVM.Pointer(LLVM::Int8), 'i8*'],
    [LLVM::Type.pointer(LLVM::Int1), 'i1*'],

    [LLVM.Function([LLVM::Int8], LLVM.Void), 'void (i8)'],
    [LLVM.Function([LLVM::Int8], LLVM::Int8), 'i8 (i8)'],
    [LLVM.Function([], LLVM::Int8), 'i8 ()'],
    [LLVM::Type.function([LLVM::Int1], LLVM.Void), 'void (i1)'],
    [LLVM::Type.function([LLVM::Int1], LLVM::Int1), 'i1 (i1)'],
    [LLVM::Type.function([], LLVM::Int1), 'i1 ()'],
  ].freeze

  describe "LLVM::Type#to_s" do
    TO_S_TESTS.each do |(type, string)|
      it "should return '#{string}'" do
        assert type.is_a?(LLVM::Type)
        assert_equal string, type.to_s
      end
    end

    it 'should have 20 tests' do
      assert_equal 20, TO_S_TESTS.size
    end
  end

end
