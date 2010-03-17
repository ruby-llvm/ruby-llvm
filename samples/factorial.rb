require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

mod = LLVM::Module.create("Factorial")
mod.functions.add("fac", [LLVM::Int], LLVM::Int) do |fac, p0|
  
  # Basic blocks
  entry   = fac.basic_blocks.append
  recur   = fac.basic_blocks.append
  result  = fac.basic_blocks.append
  
  # Locals
  fac_ = nil
  
  entry.build do |b|
    b.cond(
      b.icmp(:eq, p0, LLVM::Int(1)),
      result, recur)
  end
  
  recur.build do |b|
    fac_call = b.call(fac,
                 b.sub(p0, LLVM::Int(1)))
    fac_ = b.mul(p0, fac_call)
    b.br(result)
  end
  
  result.build do |b|
    b.ret(
      b.phi(LLVM::Int,
        LLVM::Int(1), entry,
        fac_,         recur))
  end
end

mod.verify

puts
mod.dump

provider = LLVM::ModuleProvider.for_existing_module(mod)
engine = LLVM::ExecutionEngine.create_jit_compiler(provider)

arg = (ARGV[0] || 6).to_i
value = engine.run_function(mod.functions["fac"], arg)

puts
puts "fac(%i) = %i" % [arg, value]
puts
