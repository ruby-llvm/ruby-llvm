# ForExprAST - Expression class for for/in.
class ForExprAST < ExprAST 
  def initialize(varname, start, _end, _step, _body , from)
    super(from , _body.to)
    @varName, @start, @end, @step , @body = varname, start , _end, _step, _body
  end
  def to_s
    "for #{@varName} = #{@start} , #{@end}, #{@step} in #{@body}\n"
  end
  def code(the_module , builder)
    # Output this as:
    #   var = alloca double
    #   ...
    #   start = startexpr
    #   store start -> var
    #   goto loop
    # loop:
    #   ...
    #   bodyexpr
    #   ...
    # loopend:
    #   step = stepexpr
    #   endcond = endexpr
    #
    #   curvar = load var
    #   nextvar = curvar + step
    #   store nextvar -> var
    #   br endcond, loop, endloop
    # outloop:
    theFunction = builder.insert_block.parent
    # Create an alloca for the variable in the entry block.
    alloca = builder.alloca LLVM::Double
    # Emit the start code first, without 'variable' in scope.
    return nil unless startVal = @start.code(the_module , builder)
    # Store the value into the alloca.
    builder.store(startVal, alloca)

    # Make the new basic block for the loop header, inserting after current block.
    loopBB = theFunction.basic_blocks.append
    # Insert an explicit fall through from the current block to the loopBB.
    builder.br(loopBB)
    # Start insertion in loopBB.
    builder.position_at_end(loopBB)
    # makes bariable accessible to boby code. (not shadowed as in tutorial)
    ExprAST.named_values[@varName] = alloca

    # Emit the body of the loop.  This, like any other expr, can change the current BB.  
    return nil unless loop_val = @body.code(the_module , builder)

    # Emit the step value.
    stepVal = @step.code(the_module , builder)
    return nil unless stepVal
    curVar = builder.load(alloca, @varName);
    nextVar = builder.fadd(curVar, stepVal, "nextvar")
    builder.store(nextVar, alloca)

    # Compute the end condition.
    endCond = @end.code(the_module , builder)
    return nil unless endCond
    # Create the "after loop" block and insert it.
    afterBB = theFunction.basic_blocks.append "afterloop" 
    # Convert condition to a bool by comparing equal to 0.0.
    endCond = builder.fcmp(:oeq , endCond, LLVM.Double(0.0) , "loopcond")
    # Insert the conditional branch into the end of LoopEndBB.
    builder.cond(endCond, afterBB , loopBB)
    # Any new code will be inserted in afterBB.
    builder.position_at_end(afterBB)

    # for expr always returns 0.0.
    return curVar
  end
end
