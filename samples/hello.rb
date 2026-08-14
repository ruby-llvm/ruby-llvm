# LLVM 'Hello, World!' example from
# http://llvm.org/docs/LangRef.html#module-structure
require 'llvm/core'
require 'llvm/execution_engine'

HELLO_STRING = "Hello, World!"

# modules hold functions and variables
mod = LLVM::Module.new('hello')

# Declare the string constant as a global constant.
hello = mod.globals.add(LLVM::ConstantArray.string(HELLO_STRING) , :hello) do |var|
  var.linkage = :private
  var.global_constant = true
  var.unnamed_addr = true
  var.initializer = LLVM::ConstantArray.string(HELLO_STRING)
end

# External declaration of the `puts` function
cputs = mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
  function.add_attribute :no_unwind_attribute
  string.add_attribute :no_capture_attribute
end

# Definition of main function
# a function is made up of connected BasicBlocks and must have _one entry and exit
# basic blocks are (mostly) simple machine instructions and can be connected in a graph
main = mod.functions.add('main', [], LLVM::Int32) do |function|
  function.basic_blocks.append.build do |b|
    zero = LLVM.Int(0) # a LLVM Constant value

    # Read here what GetElementPointer (gep) means http://llvm.org/releases/3.2/docs/GetElementPtr.html
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

LLVM.init_jit

# 32-bit x86 JIT fixups: realign the stack (LLVM assumes 16-byte, Ruby calls in 4-byte) and
# register puts as _puts (i386 underscore mangling). No-op on 64-bit / Unix.
if FFI::Platform::ADDRESS_SIZE == 32 && (FFI::Platform::IS_WINDOWS || FFI::Platform::OS == 'cygwin')
  mod.functions.each { |f| f.add_attribute(LLVM::Attribute.string('stackrealign', '')) }
  puts_ptr = FFI::DynamicLibrary.open(FFI::Library::LIBC, FFI::DynamicLibrary::RTLD_LAZY).find_function('puts')
  LLVM::C.add_symbol('_puts', puts_ptr) if puts_ptr
end

engine = LLVM::JITCompiler.new(mod)
engine.run_function(main)
engine.dispose
