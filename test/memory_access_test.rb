require "test_helper"

class MemoryAccessTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_jit
  end

  def test_memory_access
    assert_equal 1 + 2, simple_memory_access_function(1, 2).to_i
    assert_equal 3 + 4, array_memory_access_function(3, 4).to_i
  end

  def simple_memory_access_function(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer1 = builder.alloca(LLVM::Int)
      pointer2 = builder.alloca(LLVM::Int)
      builder.store(arguments.first, pointer1)
      builder.store(arguments.last, pointer2)
      builder.ret(builder.add(builder.load(pointer1), builder.load(pointer2)))
    end
  end

  def array_memory_access_function(value1, value2)
    run_function([LLVM::Int, LLVM::Int], [value1, value2], LLVM::Int) do |builder, function, *arguments|
      entry = function.basic_blocks.append
      builder.position_at_end(entry)
      pointer = builder.array_alloca(LLVM::Int, LLVM::Int(2))
      builder.store(arguments.first, builder.gep(pointer, [LLVM::Int(0)]))
      builder.store(arguments.last, builder.gep(pointer, [LLVM::Int(1)]))
      builder.ret(builder.add(builder.load(builder.gep(pointer, [LLVM::Int(0)])),
                              builder.load(builder.gep(pointer, [LLVM::Int(1)]))))
    end
  end

end
