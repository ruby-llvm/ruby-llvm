require "simple_ast"

# VariableExprAST - Expression class for referencing a variable, like "a".
class VariableExprAST < ExprAST 
  attr_accessor :name
  def initialize(name , from , to)
    super(from , to)
    @name = name
  end
  def to_s
    "#{@name}"
  end
  def code the_module , builder
    # Look this variable up in the function.
    value = @@named_values[@name]
    return error("Variable unknown #{@name}") if value == nil 
    # Load the value.
    return builder.load(value, @name)
  end
end


# VarExprAST - Expression class for var/in
class VarExprAST < ExprAST
  #std::vector<std::pair<std::string, ExprAST*> >   varNames
  def initialize(varnames, body , from , to)
    super(from , to)
    @varNames , @body = varnames , body
  end
  def to_s
    "#{@varNames} #{@body}"
  end
  def code(the_module , builder) 
    oldBindings = {}

    theFunction = builder.insert_block.parent
    # Register all variables and emit their initializer.
    varNames.each do |varName , oldBindings|
      # Emit the initializer before adding the variable to scope, this prevents
      # the initializer from referencing the variable itself, and permits stuff
      # like this:
      #  var a = 1 in
      #    var a = a in ...   # refers to outer 'a'.
      oldBindingsVal = nil
      if (oldBindings) 
        oldBindingsVal = oldBindings.code(the_module , builder)
        return nil unless oldBindingsVal
      else # If not specified, use 0.0.
        oldBindingsVal = LLVM.Double(0)
      end

      alloca = createEntryBlockalloca(theFunction, varName)
      builder.store(oldBindingsVal, alloca)

      # Remember the old variable binding so that we can restore the binding when
      # we unrecurse.
      oldBindings[varName] <<@@named_values[varName]

      # Remember this binding.
     @@named_values[varName] = alloca
    end

    # code the body, now that all vars are in scope.
    return nil unless bodyVal = body.code(the_module , builder)

    # Pop all our variables from scope.
    varNames.each do |first, second|
     @@named_values[first] = oldBindings[first]
    end
    # Return the body computation.
    return BodyVal
  end
end
