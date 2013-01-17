require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_jit

mod = LLVM::Module.new("Function Pointers")

F  = LLVM::Function([LLVM::Int], LLVM::Int)
FP = LLVM::Pointer(F)

mod.functions.add("f", [LLVM::Int], LLVM::Int) do |f, n|
  f.basic_blocks.append("entry").build do |b|
    b.ret(b.add(LLVM::Int(1), n))
  end
end

mod.functions.add("g", [FP, LLVM::Int], LLVM::Int) do |g, fp, n|
  g.basic_blocks.append("entry").build do |b|
    b.ret(b.call(fp, n))
  end
end

mod.functions.add("test", [], LLVM::Int) do |test|
  test.basic_blocks.append("entry").build do |b|
    b.ret(b.call(mod.functions["g"],
                 mod.functions["f"],
                 LLVM::Int(41)))
  end
end

mod.verify
mod.dump

jit = LLVM::JITCompiler.new(mod)
puts jit.run_function(mod.functions["test"]).to_i
