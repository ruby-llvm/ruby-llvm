require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

# must initialize the jit
LLVM.init_jit

# modules are translation units, ie files usually
mod = LLVM::Module.new("Function Pointers")

# define a function that takes an int and returns an int
F  = LLVM::Function([LLVM::Int], LLVM::Int)
FP = LLVM::Pointer(F) # and a pointer to such a function

# we add a function to the module and then add blocks to it. n is the argument
mod.functions.add("add_one", [LLVM::Int], LLVM::Int) do |function, n|
  # basic blocks are the smallest execution unit and there must always be _one_ entry and exit point
  function.basic_blocks.append("entry").build do |b|
    # create a block to add the Constant integer (Value) 1
    add = b.add(LLVM.Int(1), n)
    b.ret( add ) # and return that value (add the block that returns the value)
  end
end

# define a function that takes a function and executes it with the given argument
# in effect implementing block logic.
mod.functions.add("adder", [FP, LLVM::Int], LLVM::Int) do |function, fp, n|
  function.basic_blocks.append("entry").build do |b|
    value = b.call2(F, fp, n) # that's creating a block to call the function we received
    b.ret(value) # and we return the value that the function returned
  end
end

# create the test function that will execute the adder with add_one
# def test                              def adder method , arg      def add_one arg
#   adder( :add_one , 41)                   method(arg)                arg + 1
# end                                   end                          end
mod.functions.add("test", [], LLVM::Int) do |test|
  test.basic_blocks.append("entry").build do |b|
    adder = mod.functions["adder"]
    add_one = mod.functions["add_one"]
    b.ret(b.call(adder, add_one, LLVM::Int(41)))
  end
end

mod.verify
mod.dump

jit = LLVM::JITCompiler.new(mod)
puts jit.run_function(mod.functions["test"]).to_i
