# PrototypeAST - This class represents the "prototype" for a function,
# which captures its name, and its argument names (thus implicitly the number
# of arguments the function takes), as well as if it is an operator.
class PrototypeAST < ExprAST
  
  def initialize(name, args, isoperator = false, prec = 0  , from , to)
    super(from , to)
    @name , @args , @isOperator , @precedence  = name , args, isoperator ,prec
  end
  def to_s
    "#{@name} , #{@args} , #{@isOperator} , #{@precedence}"
  end
  def isUnaryOp
    return @isOperator && @args.length == 1 
  end

  def isBinaryOp
    return @isOperator && @args.length == 2 
  end

  def getOperatorName
    trow self unless isUnaryOp || isBinaryOp
    return @name[@name.length - 1]
  end

  def getBinaryPrecedence 
    return @precedence 
  end

  # CreateArgumentAllocas - Create an alloca for each argument and register the
  # argument in the symbol table so that references to it will succeed.
  def createArgumentAllocas(function , builder)
    function.params.each do |param|
      alloc = builder.alloca param
      builder.store param , alloc
      # Add arguments to variable symbol table.
      ExprAST.named_values[param.name] = alloc
      #puts "Alloca #{param.name} = #{alloc}"
    end
  end

  def code(the_module , builder)
    # If there was already something named 'Name'.  If it has a
    # body, don't allow redefinition or reextern.
    if (was = the_module.functions.named(@name))
      # If F already has a body, reject this.
      return error("redefinition of function") unless was.empty

      # If F took a different number of args, reject.
      return error("redefinition of function with different # args") if (was.params.size != @args.length) 
      function = was
    else
      # Make the function type:  double(double,double) etc.
      function = the_module.functions.add( @name , [LLVM::Double] * @args.length , LLVM::Double )
      function.linkage = :external
    end

    # Set names for all arguments.
    @args.each_with_index do |arg,index|
      function.params[index].name = arg
    end
    return function
  end
end

