# LLVM 'Hello, World!' example from
# http://llvm.org/docs/LangRef.html#module-structure
require 'llvm/core'
require 'llvm/execution_engine'

HELLO_STRING = "Hello, World!"

mod = LLVM::Module.new('hello')

# Declare the string constant as a global constant.
hello = mod.globals.add(LLVM.Array(LLVM::Int8, HELLO_STRING.size + 1), '.str') do |var|
  var.linkage = :private
  var.global_constant = 1
  var.unnamed_addr = true
  var.initializer = LLVM::ConstantArray.string(HELLO_STRING)
end

# External declaration of the `puts` function
cputs = mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
  function.add_attribute :no_unwind_attribute
  string.add_attribute :no_capture_attribute
end

# Definition of main function
main = mod.functions.add('main', [], LLVM::Int32) do |function|
  function.basic_blocks.append.build do |b|
    zero = LLVM.Int(0)

    # Convert [13 x i8]* to i8  *...
    cast210 = b.gep hello, [zero, zero], 'cast210'
    # Call puts function to write out the string to stdout.
    b.call cputs, cast210
    b.ret zero
  end
end

mod.dump
#mod.dispose
puts "------------------------------"

LLVM.init_x86

engine = LLVM::JITCompiler.new(mod)
engine.run_function(main)
engine.dispose
