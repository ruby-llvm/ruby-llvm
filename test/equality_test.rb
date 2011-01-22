require "test_helper"
require "llvm/core"

class EqualityTestCase < Test::Unit::TestCase

	def setup
    LLVM.init_x86
	end

	def test_module
		mod = LLVM::Module.create('test')
		assert_equal mod, mod
		assert_equal mod, LLVM::Module.from_ptr(mod.to_ptr)
	end

	def test_type
    type = LLVM::Float.type
		assert_equal type, type
		assert_equal type, LLVM::Float.type
	end

	def test_function
		mod = LLVM::Module.create('test')
		fn = mod.functions.add('test', LLVM.Void)
		assert_equal fn, fn
		assert_equal fn, mod.functions.named('test')
	end

end

