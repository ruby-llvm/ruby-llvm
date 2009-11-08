require 'llvm/core'
require 'llvm/analysis'
require 'llvm/execution_engine'
require 'llvm/target'
require 'llvm/transforms/scalar'

# Initialize target
LLVM.init_x86

# Create an LLVM::Module
mod = LLVM::Module.create_with_name("Factorial")
# Add an LLVM::Function to the module
fac = mod.add_function("fac", [LLVM::Int64.type], LLVM::Int64.type)
# Create a reference to the first parameter
p0 = fac.params[0]

# Declare basic blocks
entry    = fac.append_basic_block("entry")
iftrue   = fac.append_basic_block("iftrue")
iffalse  = fac.append_basic_block("iffalse")
endblock = fac.append_basic_block("end")

# An LLVM::Builder is needed to sequence instructions
builder = LLVM::Builder.create

# Define 'entry'
builder.position_at_end(entry)
builder.cond(
  builder.icmp(:eq, p0, LLVM::Int64.from_i(1), "n == 0"),
  iftrue,
  iffalse)

# Define 'iftrue'
builder.position_at_end(iftrue)
res_iftrue = LLVM::Int64.from_i(1)
builder.br(endblock)

# Define 'iffalse'
builder.position_at_end(iffalse)
n_minus = builder.sub(p0, LLVM::Int64.from_i(1), "n - 1")
call_fac = builder.call(fac, n_minus, "fac(n - 1)")
res_iffalse = builder.mul(p0, call_fac, "n * fac(n - 1)")
builder.br(endblock)

# Define 'end'
builder.position_at_end(endblock)
builder.ret(
  builder.phi(LLVM::Int64.type, "result",
    res_iftrue,  iftrue,
    res_iffalse, iffalse))

mod.verify(:return)

puts
puts ';' * 24
puts "; Pre-optimization"
mod.dump

# Run optimizations
provider = LLVM::ModuleProvider.for_existing_module(mod)
engine   = LLVM::ExecutionEngine.create_jit_compiler(provider)
pass     = LLVM::PassManager.new_with_execution_engine(engine)
pass.add(:instruction_combining, :cfg_simplification)
pass.run(mod)

puts
puts ';' * 24
puts "; Post-optimization"
mod.dump

# Box argument in an LLVM::GenericValue for execution
n   = (ARGV[0] || 6).to_i
arg = LLVM::GenericValue.from_i(n, 64)
# Execute our JIT-compiled function
res = engine.run_function(fac, arg)
puts
puts "fac(#{n}) = %i\n" % res
