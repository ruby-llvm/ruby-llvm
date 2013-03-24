Kaleidoscope
--------------

Kaleidoscope is a toy language implemented in a tutorial on llvm.org. You can find it here http://llvm.org/docs/tutorial/LangImpl1.html

This is a ruby port of the original 1000 lines, but along with syntax  (c++ -> ruby) came a few other changes
  - no use of global variables. Specifically lexer, parser and driver (main) became classes
  - Token class plays with lexer to make tokens look like a linked list
  - as there is no ability to define external c functions, a simple put() is defined in driver
  
You can read the tutorial online, which is very good. 

General
-------

There is no extra text with this code, so I'll describe it a little: 

Kaleidoscope has only one type, float. It has just enough built in unary and binary operators, but lets you define more operators, see below. It lets you define functions with arbitrary amount of arguments, and call functions.
It also has an if statement and a for loop.

Program structure
----------------

The driver is the main, it instantiates the needed module (llvm concept) and the the parser. It also codes the put function.

Whenever anything is parsed successfully it is executed, and the output written to stdout. Any statements you write 
outside a function are wrapped in an anonymous function and executed.

At the end it dumps the module, ie all defined functions to stderr. See below for more

The Parser is a collection of functions turning Tokens into AST objects. Iti is I believe called a recursive descent
and is quite easy to follow when reading the code.

Syntax Tree
-----------

Instances of classes that are derived from ExprAST make up the syntax tree, ie the internal structure representing the 
kaleidoscope program. The classes have a little description in them as to how they are represented, and are quite 
straight forward (apart from operators). New Operators may be defined with def binary& where & can be any sign and represents 
the operator. Even a precedence may be defined (somewhat strangely for a beginners tutorial)

As a ruby addition, each node has a to_s , so we can get the code back out. This is used to tell what has been evaluated.

And off course ast nodes are responsible for creating the code they represent. The function code() returns a LLVM::Value,
a central piece in the llvm machinery. Values are constant expressions representing instructions or numbers. In llvm they 
are arranged in groups called BasicBlocks. Blocks may be seen as a flow graph of the program.

The LLVM hierachy
-----------------

To understand what the code() functions do better it is helpful to understand more about llvm. Ie read read read. But a quick 
intro:

A _Module_ is a unit of compilation. It contains Global values and Functions, in Ruby as collections which are enumerable.

A Function has a list of Parameters and BasicBlocks. Again both can be iterated, and there is a block style syntax to "build"
Blocks. As I said the blocks are the "flowchart" and as such a graph, working with them as a list can be a little confusing.
Sometimes you have to explicitly set the "insertion point".

Blocks are mode up of instructions, and that actually means Values (LLVM::Value derivatives). It is important to understand that the flow between Blocks must be _explicitly_ created. Even for blocks that are created in sequence, no 
"implicit" flow exists. An unconditional branch "br" must be added. 

There are three ways to "build" a sequence of instructions/values. The simplest is constants, ie LLVM::Int(0) is a Constant Value representing the Integer 0. Double, IntX with X 1,8,32,64 exist. LLVM is strongly typed and if you want to get a 32 int from a compare result (1 bit) you must cast (xx2xx in builder).

Another way is using a builder (class Builder) to create instructions. There are any number of them in there 
(ie i don't know them all), basic ones mul (multiply), add , icmp (integer compare), fcmp, ret (return). 
This approach is fostered by the block api ruby-llvm has. 
So you can wite module.functions.add do || and get the function and a builder. 

Similarly function.basic_blocks.append(name).build do|| will also give you a builder to build away.
The last approach is to use the values themselves. Similar functions to builders add/cmp exist on the values and you can
just call left.add(right).

As a final pointer I just want to mention the phi node, as it has no equivalent in modern programming. It is a sort of reverse
branch. If you think of a conditional branch (builder.cond) as a fanning out, a phi is the fan in reverse. It has a number of 
incoming blocks and assumes a different value, depending on where the flow comes from. And if that doesn't have
you baffled, go yonder and find out what a gep or ibr is. 

Running Kaleidoscope scripts
-----------------------------

You can run Kaleidoscope scripts by:

bundle exec ruby samples/kaleidescope/driver.rb  samples/kaleidescope/maths.kal

If you write your own scripts, you must end with an expression, not a function. This comes naturally since what would a that last function do?
But if you forget that you'll get an error about function signatures not matching.

You can also omit the file and enter your code interactively. You must ctr-d to get it evaluated though.

Executables
-----------

Yes, it's possible! Restrictions apply though and no refunds. A c main is generated for the last expression, and it needs to be an
expression, not a function (otherwise function signatures don't match).
But remember, the "Evaluated to" message comes from the ruby driver. The only output you'll see from your program is what 
your program creates, ie with put.

Start by running any .kal file and dumping the module into a file. The module comes on stderr, so for example

 bundle exec ruby samples/kaleidescope/driver.rb  samples/kaleidescope/mandel.kal 2> mandel.ll
 
will get you the mandel module as a llvm ir file. 

You can run this in 2 ways. First with the llvm interpreter, lli

  lli mandel.ll
  
will actually run the module as is. Remember, not output other that what you "put". And for the final act

  llc -O3 mandel.ll -filetype=obj -o mandel.o
  gcc mandel.o -o mandel
  ./mandel

PS: for best enjoyment use time or ls -l. The resulting program seems to have about an 8k overhead, so the mandel is several
hundred bytes. And the factorial (no output) runs about 20 times faster in exe compared to lli interpretation.

