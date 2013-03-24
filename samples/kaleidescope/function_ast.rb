# FunctionAST - This class represents a function definition itself.
class FunctionAST < ExprAST
  attr_reader :body
  def initialize(proto, body)
    super(proto.from , body.to)
    @proto, @body = proto , body
  end
  def code(the_module , builder)
    #puts "Function #{self}"
    ExprAST.named_values.clear()

    return nil unless theFunction = @proto.code(the_module , builder)

    # If this is an operator, install it.
    ExprAST.set_precedence( @proto.getOperatorName,  @proto.getBinaryPrecedence ) if @proto.isBinaryOp

    # Create a new basic block to start insertion into.
    block = LLVM::BasicBlock.create(theFunction, "entry", )
    builder.position_at_end(block)

    # Add all arguments to the symbol table and create their allocas.
    @proto.createArgumentAllocas(theFunction , builder)

    unless retVal = @body.code(the_module , builder)
      # Error reading body, remove function.
      LLVM::C.delete_function(theFunction)
      ExprAST.set_precedence(@proto.getOperatorName , nil ) if @proto.isBinaryOp
      return nil
    end
    # Finish off the function.
    builder.ret(retVal)
    # Validate the generated code, checking for consistency.
    theFunction.verify
    
    # Optimize the function.tbd   --- TheFPM.run(theFunction)
    return theFunction
  end
  def to_s
    "def #{@proto}\n#{@body}"
  end
end

