require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_jit

mod = LLVM::Module.new("Factorial")

mod.functions.add("fac", [LLVM::Int], LLVM::Int) do |fac, n|
  n.name    = "n"
  entry     = fac.basic_blocks.append("entry")
  recur     = fac.basic_blocks.append("recur")
  result    = fac.basic_blocks.append("result")
  n_fac_n_1 = nil # predeclare within function's scope

  entry.build do |b|
    test = b.icmp(:eq, n, LLVM::Int(1), "test")
    b.cond(test, result, recur)
  end

  recur.build do |b|
    n_1       = b.sub(n, LLVM::Int(1), "n-1")
    fac_n_1   = b.call(fac, n_1, "fac(n-1)")
    n_fac_n_1 = b.mul(n, fac_n_1, "n*fac(n-1)")
    b.br(result)
  end

  result.build do |b|
    fac = b.phi(LLVM::Int,
               { entry => LLVM::Int(1),
                 recur => n_fac_n_1 },
               "fac")
    b.ret(fac)
  end
end

mod.verify

puts
mod.dump

engine = LLVM::JITCompiler.new(mod)

arg = (ARGV[0] || 6).to_i
value = engine.run_function(mod.functions["fac"], arg)

printf("\nfac(%i) = %i\n\n", arg, value)

