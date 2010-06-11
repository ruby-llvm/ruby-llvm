require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

mod = LLVM::Module.create("Factorial")
mod.functions.add("fac", [LLVM::Int], LLVM::Int) do |fac, p0|
  entry   = fac.basic_blocks.append
  recur   = fac.basic_blocks.append
  result  = fac.basic_blocks.append
  
  builder = LLVM::Builder.create
  
  builder.position_at_end(entry)
  builder.cond(
    builder.icmp(:eq, p0, LLVM::Int(1)),
    result, recur)
  
  builder.position_at_end(recur)
  fac_call = builder.call(fac,
               builder.sub(p0, LLVM::Int(1)))
  fac_ = builder.mul(p0, fac_call)
  builder.br(result)
  
  builder.position_at_end(result)
  builder.ret(
    builder.phi(LLVM::Int,
      LLVM::Int(1), entry,
      fac_,         recur))
end

mod.verify

puts
mod.dump

engine = LLVM::ExecutionEngine.create_jit_compiler(mod)

arg = (ARGV[0] || 6).to_i
value = engine.run_function(mod.functions["fac"], arg)

printf("\nfac(%i) = %i\n\n", arg, value)

