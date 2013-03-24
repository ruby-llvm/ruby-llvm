require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'
require "benchmark"

# run this with any argument to get a speed comparison between llvm and different ruby implementations

# Start the "engine" before driving
LLVM.init_jit

# modules hold functions and variables
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
mod.dump

engine = LLVM::JITCompiler.new(mod)

def rec_factorial(n)
  if n <= 1
    1
  else
    n * rec_factorial(n - 1);
  end
end
def iter_factorial(n)
  nn = n
  i = n - 1
  while(i > 1) do
    nn *= i
    i -= 1
  end
  return nn;
end
def array_factorial(n)
    (1..n).inject(:*)
end

if( ARGV.length == 0 )
  puts "Single run with 42 = "  + engine.run_function(mod.functions["fac"], 42).to_i.to_s
  exit
end
puts "Times show factorial execution times in milliseconds. Both for llvm and ruby iterative and recusive algorithms"
puts ["Num" , "llvm rec","recursive" ,"iterative","arrar iter."].collect{|u|u.ljust(11)}.join
res = [ 1, 5 , 20 , 50 , 100 , 200 , 500 , 1000 , 2000 , 5000  ].each do |i|
  res = [ ]
  res << Benchmark.realtime {engine.run_function(mod.functions["fac"], i)}
  res << Benchmark.realtime {rec_factorial(i)}
  res << Benchmark.realtime {iter_factorial(i) }
  res << Benchmark.realtime {array_factorial(i) }
  res = [i] + res.collect {|u| ((u*1000)).round(4) }
  res = res.collect {|z| z.to_s.ljust(8)}
  next if i < 10
  puts res.join("   ")
end


