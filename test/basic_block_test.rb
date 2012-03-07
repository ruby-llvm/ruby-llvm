require "test_helper"

class BasicBlockTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
    @module = LLVM::Module.new("BasicBlockTestCase")
  end

  def test_basic_block_collection
    @module.functions.add("test_basic_block_collection", [], LLVM.Void) do |fn|
      coll = fn.basic_blocks

      block1 = coll.append
      assert_instance_of LLVM::BasicBlock, block1

      assert_equal 1, coll.size
      assert_equal coll.first, coll.last,
                   'Only one block exists in the function'
      assert_equal coll.first, coll.entry,
                   'The entry block for the function is always the first block'

      block2 = coll.append
      assert_equal 2, coll.size
      assert_equal block1, coll.first
      assert_equal block2, coll.last

      [ coll.each.to_a, coll.to_a ].each do |blocks|
        assert_equal 2, blocks.size
        assert_equal block1, blocks[0]
        assert_equal block2, blocks[1]
      end
    end
  end

  def test_basic_block
    @module.functions.add("test_basic_block", [], LLVM.Void) do |fn|
      coll = fn.basic_blocks

      block1 = coll.append
      block2 = coll.append

      assert_equal fn, block1.parent
      assert_equal fn, block2.parent

      assert_equal block2, block1.next
      assert_equal block1, block2.previous

      block1.build do |builder|
        builder.br(block2)
      end

      block2.build do |builder|
        builder.ret_void
      end

      assert_equal block1.first_instruction,
                   block1.last_instruction
      assert_equal block2.first_instruction,
                   block2.last_instruction
    end
  end

  def test_basic_block_enumerable
    @module.functions.add("test_basic_block_enumerable", [LLVM::Double], LLVM::Double) do |fn, arg|
      block1 = fn.basic_blocks.append

      [ block1.instructions.to_a, block1.instructions.each.to_a ].each do |insts|
        assert_equal 0, insts.size, 'Empty basic block'
      end

      block1.build do |builder|
        builder.ret(builder.fadd(arg, LLVM.Double(1.0)))
      end

      [ block1.instructions.to_a, block1.instructions.each.to_a ].each do |insts|
        assert_equal 2, insts.size
        assert_equal block1.first_instruction, insts[0]  # deprecated
        assert_equal block1.last_instruction,  insts[1]  # deprecated
        assert_equal block1.instructions.first, insts[0]
        assert_equal block1.instructions.last,  insts[1]
      end

    end
  end

end

