require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

mod = LLVM::Module.create_with_name("Factorial")
mod.add_function("fac", [LLVM::Int], LLVM::Int) do |fac, p0|
  builder = LLVM::Builder.create
  
  # Basic blocks
  entry   = fac.basic_blocks.append
  recur   = fac.basic_blocks.append
  result  = fac.basic_blocks.append
  
  # Locals
  fac_ = nil
  
  builder.with_block(entry) do
    builder.cond(
      builder.icmp(:eq, p0, LLVM::Int(1)),
      result, recur)
  end
  
  builder.with_block(recur) do
    fac_call = builder.call(fac,
                 builder.sub(p0, LLVM::Int(1)))
    fac_ = builder.mul(p0, fac_call)
    builder.br(result)
  end
  
  builder.with_block(result) do
    builder.ret(
      builder.phi(LLVM::Int,
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
value = engine.run_function(mod.named_function("fac"), arg)

puts
puts "fac(%i) = %i" % [arg, value]
puts
