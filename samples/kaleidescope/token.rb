
# tokens are a linked list. one way only, as the call stack provides the other direction
# this provides for "infinate" lookahead (but lazily)
# kind is a symbol denoting the kind (identifier/number... see lexer)
class Token
  attr_reader  :line_number , :value , :kind
  def initialize line_number , value , kind , lexer
    @line_number , @value , @kind = line_number , value , kind
    @next = lexer
  end
  # lazily resolve the next. Ie for the last in a line, we set the lexer as the next and resolve from it if needed
  def next
    if @next.is_a? Lexer  #this changes the next variable
      #puts "READLINE"
      @next.readline(self) 
    end
    @next
  end
  # can be used to "collapse" several successicve lexer tokens to parser token without too much shuffeling
  def next= n
    @next = n
  end
  def ascii?
    @value.match(/[a-zA-Z]/)
  end
  def to_s
    "#{value}:#{kind}"
  end
  def all
    "#{value} #{self.next.all if self.next}"
  end
end

