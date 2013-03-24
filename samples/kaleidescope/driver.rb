#===----------------------------------------------------------------------===#
# Top-Level parsing and JIT Driver
#===----------------------------------------------------------------------===#
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'
require "parser"

#static ExecutionEngine *TheExecutionEngine

class Driver
  def initialize fname
    LLVM.init_jit
    @parser = Parser.new (fname ? File.open( fname ) : $stdin )
    @module = LLVM::Module.new("Kaleidescope")
    @builder = LLVM::Builder.new
    @engine = LLVM::JITCompiler.new(@module)
    # We define a putchard (as per tutorial chapter 6), as we cant link it in by writing c
    # to do that we do need to define the putchar (stdlibc take a int as external first)
    putchar = @module.functions.add( "putchar" , [LLVM::Int] , LLVM::Int )
    putchar.linkage = :external
    @module.functions.add("put", [LLVM::Double], LLVM::Double) do |function , arg|
      function.basic_blocks.append.build do |builder|
        # Call putchar function to write out the char to stdout.
        builder.call(putchar, builder.fp2ui(arg , LLVM::Int))
        builder.ret arg
      end
    end
  end

  # top ::= definition | external | expression | ''
  def mainLoop
    token = @parser.start
    while token
      token = token.next if ";" == token.value
      return if token.kind == :eof
      case token.value
      when "def"
        if function_ast = @parser.parseDefinition(token)
          if function_code = function_ast.code(@module ,@builder)
            #puts "Read function definition:"
            #function_code.dump
          end
          token = function_ast.to
          #puts "Next Token #{token}"
        else # Skip token for error recovery.
          token.next
        end
      when "extern"
        if proto = @parser.parseExtern(token)
          if function = proto.code(@module ,@builder)
            puts "Read extern: "
            function.dump
          end
          token = proto.to
        else # Skip token for error recovery.
          token.next
        end
      else
        # Evaluate a top-level expression into an anonymous function.
        if functionAST = @parser.parseTopLevelExpr(token)
          if function = functionAST.code(@module ,@builder)
            res = @engine.run_function function
            puts "Evaluated #{functionAST.body} to #{res.to_f(LLVM::Double.type)}"
          end
          token = functionAST.to
        else # Skip token for error recovery.
          token.next
        end
      end
    end
  end
  def dump
    # create a main entry for the first expression
    zero = @module.functions.last
    raise "no" unless zero
    @module.functions.add("main", [LLVM::Int], LLVM::Int) do |function , arg|
      function.basic_blocks.append.build do |builder|
        # Call putchar function to write out the char to stdout.
        builder.call(zero)
        builder.ret LLVM::Int(0)
      end
    end
    
    @module.dump
  end
end

#===----------------------------------------------------------------------===#
# Main driver code.
#===----------------------------------------------------------------------===#

driver = Driver.new ARGV[0]
driver.mainLoop
driver.dump

#===----------------------------------------------------------------------===#
# "Library" functions that can be "extern'd" from user code.
#===----------------------------------------------------------------------===#

# putchard - putchar that takes a double and returns 0.
#extern "C"
#double putchard(double X) {
#  putchar((char)X)
#  return 0
#}

# printd - printf that takes a double prints it as "%f\n", returning 0.
#extern "C"
#double printd(double X) {
#  printf("%f\n", X)
#  return 0
#}


#  FunctionPassManager OurFPM(TheModule)

  # Set up the optimizer pipeline.  Start with registering info about how the
  # target lays out data structures.
#  OurFPM.add(new DataLayout(*TheExecutionEngine->getDataLayout()))
  # Provide basic AliasAnalysis support for GVN.
#  OurFPM.add(createBasicAliasAnalysisPass())
  # Promote allocas to registers.
#  OurFPM.add(createPromoteMemoryToRegisterPass())
  # Do simple "peephole" optimizations and bit-twiddling optzns.
#  OurFPM.add(createInstructionCombiningPass())
  # Reassociate expressions.
#  OurFPM.add(createReassociatePass())
  # Eliminate Common SubExpressions.
#  OurFPM.add(createGVNPass())
  # Simplify the control flow graph (deleting unreachable blocks, etc).
#  OurFPM.add(createCFGSimplificationPass())

#  OurFPM.doInitialization()


