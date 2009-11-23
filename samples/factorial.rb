require 'llvm/core'
require 'llvm/analysis'
require 'llvm/execution_engine'
require 'llvm/target'
require 'llvm/transforms/scalar'

include LLVM::Builder

# Initialize target
LLVM.init_x86

# Create an LLVM::Module
mod = LLVM::Module.create_with_name "Factorial"
# Add an LLVM::Function to the module
fac = mod.define_function "fac", [LLVM::Int64], LLVM::Int64 do |p0|
  cond icmp(:eq, p0, int64(1)),
    basic_block {
      ret int64(1)
    },
    basic_block {
      ret mul(p0,
            recur(
              sub(p0, int64(1))))
    }
end
mod.verify

puts ';' * 24
puts "; Pre-optimization"
mod.dump

# Run optimizations
provider = LLVM::ModuleProvider.for_existing_module(mod)
engine   = LLVM::ExecutionEngine.create_jit_compiler(provider)
pass     = LLVM::PassManager.new_with_execution_engine(engine)
pass.add(:instruction_combining, :cfg_simplification, :gvn)
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
