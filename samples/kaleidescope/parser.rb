require "lexer"
require "variable_ast"
require "prototype_ast"
require "function_ast"
require "for_ast"
require "if_ast"
#===----------------------------------------------------------------------===#
# Parser
#===----------------------------------------------------------------------===#
class Parser
  
  def initialize stream = $stdin
    puts "ready> " if stream == $stdin
    @lexer = Lexer.new stream
  end
  def start
    dummy = Token.new( :some , :such , :garble , self)
    @lexer.readline dummy
    return dummy.next
  end

  # Error* - These are little helper functions for error handling.
  def error(message) 
    puts  "Error: #{message}"
    nil # return nil for chaining, ie return error("went wrong")
  end
  # and the common case where we expect a certain token but son't find it (ie closing brace, or then after if)
  def mismatch( expected , got )
    raise ( "expected #{expected}, not -#{got.value}- :#{got.kind}:")
  end
  # identifierexpr
  #   ::= identifier
  #   ::= identifier '(' expression* ')'
  def parseIdentifierExpr token
    from = token
    identifier = token.value
    token = token.next  # eat identifier.
    #puts "parseIdentifierExpr #{identifier} token #{token}"
    return VariableExprAST.new(identifier, from , token) if token.value != "(" # Simple variable ref.
    # Call expression.
    token = token.next  # eat (
    args = []
    if token.value != ")"
      while true
        arg = parseExpression(token)
        return nil unless arg
        token = arg.to
        #puts "ARGS #{args} #{arg.class}"
        args[args.length] = arg
        #puts "ARGS #{args}"
        break if token.value == ")"
        return mismatch(" ')' or ',' in argument list" ,token) if token.value != ","
        token = token.next  # eat ,
      end
    end
    token = token.next  # Eat the ')'.
    #puts "Creating call with #{args}"
    return CallExprAST.new(identifier, args , from , token)
  end

  # numberexpr ::= number
  def parseNumberExpr token
    #puts "parseNumberExpr #{token}"
    return NumberExprAST.new(token.value , token , token.next )
  end

  # parenexpr ::= '(' expression ')'
  def parseParenExpr token
    #puts "parseParenExpr #{token}"
    token = token.next  # eat (.
    return nil unless expr = parseExpression(token)
    token = expr.to
    return mismatch("')'" , token) if(token.value != ")")
    expr.advance  # eat ).
    return expr
  end

  # ifexpr ::= 'if' expression 'then' expression 'else' expression
  def parseIfExpr token
    #puts "parseIfExpr #{token}"
    from = token
    token = token.next  # eat the if.
    return nil unless condition = parseExpression(token)
    token = condition.to
    return mismatch("then" , token) if (token.value != "then")
    token = token.next # eat the then
    return nil unless _then = parseExpression(token)
    token = _then.to
    return mismatch("else" , token) if (token.value != "else")
    token = token.next # eat the else
    return nil unless _else = parseExpression(token) # eat the else
    token = _else.to
    return IfExprAST.new(condition, _then, _else)
  end

  # forexpr ::= 'for' identifier '=' expr ',' expr (',' expr)? 'in' expression
  def parseForExpr token
    #puts "parseForExpr #{token}"
    from = token
    token = token.next  # eat the for.
    return mismatch("identifier after for") if token.kind != :identifier
    identifier = token.value
    token = token.next  # eat identifier.
    return mismatch("'=' after for" , token) if token.value != "="
    token = token.next  # eat '='.
    return nil unless start = parseExpression(token)
    token = start.to
    return mismatch("',' after for start value", token) if token.value != ","
    token = token.next  # eat ','.
    return nil unless _end = parseExpression(token)
    token = _end.to
    # The step value is optional.
    if token.value == ","
      token = token.next #eat the ,
      return nil unless step = parseExpression(token)
      token = step.to
    else
      step = NumberExprAST.new(1.0 , token , token)
    end
    return mismatch("'in' after for" , token ) if token.value != "in"
    token = token.next  # eat "in".
    return unless body = parseExpression(token)
    return ForExprAST.new(identifier, start, _end, step, body , from)
  end

  # varexpr ::= 'var' identifier ('=' expression)?
  #                    (',' identifier ('=' expression)?)* 'in' expression
  def parseVarExpr
    #puts "parseVarExpr #{token}"
    nextToken  # eat the var.
    varNames = [] # of arrays of 2
    # At least one variable name is required.
    return mismatch("identifier after var") if token != :identifier
    while (1) 
      name = @lexer.current_identifier
      nextToken  # eat identifier.
      # Read the optional initializer.
      init = nil
      if token == '='
        nextToken # eat the '='.
        return nil unless init = parseExpression
      end
      varNames << [name, init]
      break if (token != ',') # End of var list, exit loop.
      nextToken # eat the ','.
      return mismatch("identifier list after var") if token != :identifier
    end
    # At this point, we have to have 'in'.
    return mismatch("'in' keyword after 'var'") if token != :tok_in
    nextToken  # eat 'in'.
    return nil unless body = parseExpression
    return VarExprAST.new(varNames, body)
  end

  # primary
  #   ::= identifierexpr
  #   ::= numberexpr
  #   ::= parenexpr
  #   ::= ifexpr
  #   ::= forexpr
  #   ::= varexpr
  def parsePrimary token
    #puts "parsePrimary #{token}"
    case token.kind
    when :single
      return parseParenExpr(token) if(token.value == "(")
    when :identifier
      case token.value
      when "if"
        return parseIfExpr token
      when "for"
        return parseForExpr token
      when "var"
        return parseVarExpr token
      else
        return parseIdentifierExpr token
      end
    when :number
      return parseNumberExpr token
    else
      return mismatch("a primary expression" , token)
    end
  end

  # unary
  #   ::= primary
  #   ::= '!' unary
  def parseUnary token
    from = token
    # If the current token is not an operator, it must be a primary expr.
    #puts "parseUnary #{token}"
    return parsePrimary(token) if (token.kind != :single || token.value == "(" || token.value == ",")
    # If this is a unary operator, read it.
    #puts "parseUnary2 #{token}"
    opc = token.value
    token = token.next
    if (operand = parseUnary(token))
      return UnaryExprAST.new(opc, operand, from) 
    end
    return nil
  end

  # binoprhs
  #   ::= ('+' unary)*
  def parseBinOprhs(exprPrec, lhs)
    token = lhs.to
    #puts "parseBinOprhs #{token}"
    # If this is a binop, find its precedence.
    while true   # If this is a binop that binds at least as tightly as the current binop,
      precedence = ExprAST.precedence_for(token)    # consume it, otherwise we are done.
      #puts "Precedence for #{token} is #{precedence}, returning #{(precedence < exprPrec)}"
      return lhs if (precedence < exprPrec)
      # Okay, we know this is a binop.
      operator_precedence = ExprAST.precedence_for(token)
      operator = token.value
      token = token.next  # eat binop
      # Parse the unary expression after the binary operator.
      return nil unless rhs = parseUnary(token)
      token = rhs.to
      # If operator binds less tightly with rhs than the operator after rhs, let
      # the pending operator take rhsas its lhs .
      #puts "Precedence for #{operator} is #{operator_precedence},  #{(precedence < operator_precedence)}"
      if precedence < operator_precedence
        return nil unless rhs = parseBinOprhs(precedence+1, rhs)
        token = rhs.to
      end
      # Merge lhs /rhs.
      lhs = BinaryExprAST.new(operator, lhs , rhs)
    end
  end

  # expression
  #   ::= unary binoprhs
  def parseExpression token
    #puts "parseExpression #{token}"
    return nil unless lhs = parseUnary(token)
    return parseBinOprhs(0, lhs )
  end

  # prototype
  #   ::= id '(' id* ')'
  #   ::= binary LETTER number? (id, id)
  #   ::= unary LETTER (id)
  def parsePrototype token
    #puts "parsePrototype #{token}"
    function_name = ""
    kind = 0 # 0 = identifier, 1 = unary, 2 = binary.
    precedence = 30
    from = token
    case token.value
    when "unary"
      token = token.next
      return mismatch("unary operator" , token) unless token.kind == :single
      function_name = "unary#{token.value}"
      kind = 1
      token = token.next
    when "binary"
      token = token.next
      return mismatch("binary operator" , token) unless token.kind == :single
      function_name = "binary#{token.value}"
      kind = 2
      token = token.next
      # Read the precedence if present.
      if (token.kind == :number)
        precedence = token.value.to_i  # save because we checked the token
        return error("Invalid precedecnce: must be 1..100") if (precedence < 1 || precedence > 100)
        precedence = precedence
        token = token.next
      end
    else
      if token.kind == :identifier
        function_name = token.value
        puts "Function parsed #{function_name}"
        token = token.next
      else
        return mismatch("function name in prototype" , token)
      end
    end

    return mismatch("'(' in prototype #{inspect}" , token ) if (token.value != "(")
    token = token.next # eat (

    argNames = []
    while (token.kind == :identifier)
      argNames << token.value
      token = token.next
    end   
    return mismatch("')' in prototype #{argNames.length}" , token) if (token.value != ")")
    # success.
    token = token.next  # eat ')'.
    # Verify right number of names for operator.
    if (kind != 0) and (argNames.length != kind)
      return error("Invalid number of operands for operator #{argNames.length} not #{kind}") 
    end
    puts "Function parsed #{function_name} with #{argNames.join('-')}"
    return PrototypeAST.new(function_name, argNames, kind != 0, precedence , from , token)
  end

  # definition ::= 'def' prototype expression
  def parseDefinition from
    #puts "parseDefinition #{from}"
    return nil unless proto = parsePrototype(from.next)
    return nil unless expr = parseExpression(proto.to)
    return FunctionAST.new(proto, expr)
  end

  # toplevelexpr ::= expression
  def parseTopLevelExpr token
    #puts "parseTopLevelExpr #{token}"
    if expr = parseExpression(token)
      # Make an anonymous proto.
      proto = PrototypeAST.new("", [] , expr.from , expr.to)
      return FunctionAST.new(proto, expr)
    end
    return nil
  end

  # external ::= 'extern' prototype
  def parseExtern token
    #puts "parseExtern #{token}"
    return parsePrototype(token.next) # eat extern.
  end

end

