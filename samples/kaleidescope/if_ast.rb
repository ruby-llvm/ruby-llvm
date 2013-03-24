# IfExprAST - Expression class for if/then/else.
class IfExprAST < ExprAST 
  def initialize(cond, _then, _else)
    super(cond.from , _else.to)
    @cond , @then , @else = cond , _then ,  _else
  end
  def to_s
    "if (#{@cond})\nthen\n#{@then}\nelse\n#{@else}\n"
  end
  def code( the_module , builder ) 
    return nil unless condition_value = @cond.code(the_module , builder)

    # Convert condition to a bool 
    condition_value = builder.fp2ui(condition_value, LLVM::Int1 , "booltmp")

    theFunction = builder.insert_block.parent
    
    # Create blocks for the then and else cases. "merge" them in the "phi" ode"
    then_block = theFunction.basic_blocks.append "then"
    else_block = theFunction.basic_blocks.append "else"
    merge_block = theFunction.basic_blocks.append "merge"
    
    #build condition (not this does not automatically make the control flow merge after it )
    builder.cond(condition_value, then_block, else_block)

    # Emit then value, ie build the code for it at the then block.
    builder.position_at_end then_block
    return nil unless then_value = @then.code(the_module , builder)
    
    # and create explicit br==branch to the merge (note that this transfers control only, not the value)
    builder.br merge_block
    # code of 'Then' can change the current block, update then_block for the PHI.
    then_block = builder.insert_block
    
    # Emit else block.
#needed??    theFunction->getBasicBlockList().push_back(else_block)
    builder.position_at_end else_block
    return nil unless else_value = @else.code(the_module , builder)
        
    # code of 'Else' can change the current block, update else_block for the PHI.
    else_block = builder.insert_block

    # need to create an explicit branch to the merge block
    builder.br merge_block 

    # Emit merge block.
#    theFunction.basic_blocks.push_back(merge_block)
    builder.position_at_end(merge_block)

    return builder.phi(LLVM::Double, {then_block => then_value, else_block => else_value}, "iftmp")
  end

end
