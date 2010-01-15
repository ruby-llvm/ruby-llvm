require 'llvm/core'
require 'llvm/analysis'
require 'llvm/execution_engine'
require 'llvm/target'
require 'llvm/transforms/scalar'
 
LLVM.init_x86
 
context = LLVM::Context.global
mod = LLVM::Module.create_with_name_in_context("Factorial", context)
fac = mod.add_function("fac", [LLVM::Int.type], LLVM::Int.type)
fac.call_conv = :ccall
p0 = fac.params[0]
 
entry    = fac.append_basic_block("entry")
iftrue   = fac.append_basic_block("iftrue")
iffalse  = fac.append_basic_block("iffalse")
endblock = fac.append_basic_block("end")
builder  = LLVM::Builder.create
 
builder.position_at_end(entry)
builder.cond(
  builder.icmp(:eq, p0, LLVM::Int.from_i(1), "n == 0"),
  iftrue,
  iffalse)
 
builder.position_at_end(iftrue)
res_iftrue = LLVM::Int.from_i(1)
builder.br(endblock)
 
builder.position_at_end(iffalse)
n_minus = builder.sub(p0, LLVM::Int.from_i(1), "n - 1")
call_fac = builder.call(fac, n_minus, "fac(n - 1)")
res_iffalse = builder.mul(p0, call_fac, "n * fac(n - 1)")
builder.br(endblock)
 
builder.position_at_end(endblock)
builder.ret(
  builder.phi(LLVM::Int.type, "result",
    res_iftrue,  iftrue,
    res_iffalse, iffalse))
 
mod.verify(:return)
 
puts
puts "; Pre-optimization"
mod.dump
 
provider = LLVM::ModuleProvider.for_existing_module(mod)
engine = LLVM::ExecutionEngine.create_jit_compiler(provider)
 
pass = LLVM::PassManager.new_with_execution_engine(engine)
pass.add(
  :constant_propagation,
  :instruction_combining,
  :promote_memory_to_register,
  :gvn,
  :cfg_simplification)
pass.run(mod)
 
puts
puts "; Post-optimization"
mod.dump

n = (ARGV[0] || 6).to_i

puts
puts "fac(#{n}) = %i\n" % [
  engine.run_function(fac, LLVM::GenericValue.from_i(n))
]
