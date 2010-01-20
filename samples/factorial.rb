require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

mod = LLVM::Module.create_with_name("Factorial")
mod.add_function("fac", [LLVM::Int], LLVM::Int) do |fac, p0|
  entry   = fac.basic_blocks.append
  recur   = fac.basic_blocks.append
  result  = fac.basic_blocks.append
  builder = LLVM::Builder.create
  
  builder.with_block(entry) do
    builder.cond(
      builder.icmp(:eq, p0, LLVM::Int(1)),
      result, recur)
  end
  
  res_rec = nil
  builder.with_block(recur) do
    call_fac = builder.call(fac,
                 builder.sub(p0, LLVM::Int(1)))
    res_rec = builder.mul(p0, call_fac)
    builder.br(result)
  end
  
  builder.with_block(result) do
    builder.ret(
      builder.phi(LLVM::Int,
        LLVM::Int(1), fac.basic_blocks.entry,
        res_rec, recur))
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
