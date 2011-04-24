module LLVM
  class Value
    # @private
    def self.from_ptr(ptr)
      new(ptr) unless ptr.null?
    end

    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end

    # @private
    def to_ptr
      @ptr
    end

    # Checks if the value is equal to other.
    def ==(other)
      case other
      when LLVM::Value
        @ptr == other.to_ptr
      else
        false
      end
    end

    # Checks if the value is equal to other.
    def eql?(other)
      other.instance_of?(self.class) && self == other
    end

    # Returns the Value type. This is abstract and is overidden by its subclasses.
    def self.type
      raise NotImplementedError, "#{self.name}.type() is abstract."
    end

    def self.to_ptr
      type.to_ptr
    end

    # Returns the value's type.
    def type
      Type.from_ptr(C.LLVMTypeOf(self))
    end

    # Returns the value's name.
    def name
      C.LLVMGetValueName(self)
    end

    # Sets the value's name to str.
    def name=(str)
      C.LLVMSetValueName(self, str)
      str
    end

    # Print the value's IR to stdout.
    def dump
      C.LLVMDumpValue(self)
    end

    # Returns whether the value is constant.
    def constant?
      case C.LLVMIsConstant(self)
      when 0 then false
      when 1 then true
      end
    end

    # Returns whether the value is null.
    def null?
      case C.LLVMIsNull(self)
      when 0 then false
      when 1 then true
      end
    end

    # Returns whether the value is undefined.
    def undefined?
      case C.LLVMIsUndef(self)
      when 0 then false
      when 1 then true
      end
    end

    # Adds attr to this value's attributes.
    def add_attribute(attr)
      C.LLVMAddAttribute(self, attr)
    end
  end

  class Argument < Value
  end

  class BasicBlock < Value
    # Creates a basic block for the given function with the given name.
    def self.create(fun = nil, name = "")
      self.from_ptr(C.LLVMAppendBasicBlock(fun, name))
    end

    # Build the basic block with the given builder. Creates a new one if nil. Yields the builder.
    def build(builder = nil)
      if builder.nil?
        builder = Builder.create
        islocal = true
      else
        islocal = false
      end
      builder.position_at_end(self)
      yield builder
    ensure
      builder.dispose if islocal
    end

    # Returns the parent of this basic block (a Function).
    def parent
      fp = C.LLVMGetBasicBlockParent(self)
      LLVM::Function.from_ptr(fp) unless fp.null?
    end

    # Returns the next basic block in the sequence.
    def next
      ptr = C.LLVMGetNextBasicBlock(self)
      BasicBlock.from_ptr(ptr) unless ptr.null?
    end

    # Returns the previous basic block in the sequence.
    def previous
      ptr = C.LLVMGetPreviousBasicBlock(self)
      BasicBlock.from_ptr(ptr) unless ptr.null?
    end

    def first_instruction  # deprecated
      instructions.first
    end

    def last_instruction  # deprecated
      instructions.last
    end

    # Returns an Enumerable of the Instructions in the current block.
    def instructions
      @instructions ||= InstructionCollection.new(self)
    end

    # @private
    class InstructionCollection
      include Enumerable

      def initialize(block)
        @block = block
      end

      # Iterates through each Instruction in the collection.
      def each
        return to_enum :each unless block_given?
        inst, last = first, last

        while inst
          yield inst
          break if inst == last
          inst = inst.next
        end

        self
      end

      # Returns the first Instruction in the collection.
      def first
        ptr = C.LLVMGetFirstInstruction(@block)
        LLVM::Instruction.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last Instruction in the collection.
      def last
        ptr = C.LLVMGetLastInstruction(@block)
        LLVM::Instruction.from_ptr(ptr) unless ptr.null?
      end
    end
  end

  class User < Value
    # Returns an Enumerable of the operands in this user.
    def operands
      @operand_collection ||= OperandCollection.new(self)
    end

    # @private
    class OperandCollection
      include Enumerable

      def initialize(user)
        @user = user
      end

      # Get a reference to an operand by index.
      def [](i)
        ptr = C.LLVMGetOperand(@user, i)
        Value.from_ptr(ptr) unless ptr.null?
      end

      # Set or replace an operand by index.
      def []=(i, v)
        C.LLVMSetOperand(@user, i, v)
      end

      # Returns the number of operands in the collection.
      def size
        C.LLVMGetNumOperands(@user)
      end

      # Iterates through each operand in the collection.
      def each
        return to_enum :each unless block_given?
        0.upto(size-1) { |i| yield self[i] }
        self
      end
    end
  end

  class Constant < User
    # Creates a null constant of Type.
    def self.null(type)
      from_ptr(C.LLVMConstNull(type))
    end

    # Creates a undefined constant of Type.
    def self.undef(type)
      from_ptr(C.LLVMGetUndef(type))
    end

    # Creates a null pointer constant of Type.
    def self.null_ptr(type)
      from_ptr(C.LLVMConstPointerNull(type))
    end

    # Bitcast this constant to Type.
    def bitcast_to(type)
      ConstantExpr.from_ptr(C.LLVMConstBitCast(self, type))
    end

    # Returns the element pointer at the given indices of the constant.
    # For more information on gep go to: http://llvm.org/docs/GetElementPtr.html
    def gep(*indices)
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return ConstantExpr.from_ptr(
          C.LLVMConstGEP(self, indices_ptr, indices.size))
      end
    end
  end

  module Support
    def allocate_pointers(size_or_values, &block)
      if size_or_values.is_a?(Integer)
        raise ArgumentError, 'block not given' unless block_given?
        size = size_or_values
        values = (0...size).map { |i| yield i }
      else
        values = size_or_values
        size = values.size
      end
      FFI::MemoryPointer.new(:pointer, size).write_array_of_pointer(values)
    end

    module_function :allocate_pointers
  end

  class ConstantArray < Constant
    def self.string(str, null_terminate = true)
      from_ptr(C.LLVMConstString(str, str.length, null_terminate ? 0 : 1))
    end

    # ConstantArray.const(type, 3) {|i| ... } or
    # ConstantArray.const(type, [...])
    def self.const(type, size_or_values, &block)
      vals = LLVM::Support.allocate_pointers(size_or_values, &block)
      from_ptr C.LLVMConstArray(type, vals, vals.size / vals.type_size)
    end
  end

  class ConstantExpr < Constant
  end

  class ConstantInt < Constant
    def self.all_ones
      from_ptr(C.LLVMConstAllOnes(type))
    end

    # Creates a ConstantInt from an integer.
    def self.from_i(n, signed = true)
      from_ptr(C.LLVMConstInt(type, n, signed ? 1 : 0))
    end

    def self.parse(str, radix = 10)
      from_ptr(C.LLVMConstIntOfString(type, str, radix))
    end

    # Negation.
    def -@
      self.class.from_ptr(C.LLVMConstNeg(self))
    end

    # Boolean negation.
    def not
      self.class.from_ptr(C.LLVMConstNot(self))
    end

    # Addition.
    def +(rhs)
      self.class.from_ptr(C.LLVMConstAdd(self, rhs))
    end

    # "No signed wrap" addition. See
    # http://llvm.org/docs/LangRef.html#i_add for discusison.
    def nsw_add(rhs)
      self.class.from_ptr(C.LLVMConstNSWAdd(self, rhs))
    end

    # Multiplication.
    def *(rhs)
      self.class.from_ptr(C.LLVMConstMul(self, rhs))
    end

    # Unsigned division.
    def udiv(rhs)
      self.class.from_ptr(C.LLVMConstUDiv(self, rhs))
    end

    # Signed division.
    def /(rhs)
      self.class.from_ptr(C.LLVMConstSDiv(self, rhs))
    end

    # Unsigned remainder.
    def urem(rhs)
      self.class.from_ptr(C.LLVMConstURem(self, rhs))
    end

    # Signed remainder.
    def rem(rhs)
      self.class.from_ptr(C.LLVMConstSRem(self, rhs))
    end

    # Integer AND.
    def and(rhs)
      self.class.from_ptr(C.LLVMConstAnd(self, rhs))
    end

    # Integer OR.
    def or(rhs)
      self.class.from_ptr(C.LLVMConstOr(self, rhs))
    end

    # Integer XOR.
    def xor(rhs)
      self.class.from_ptr(C.LLVMConstXor(self, rhs))
    end

    # Integer comparison using the predicate specified via the first parameter.
    # Predicate can be any of:
    #   :eq  - equal to
    #   :ne  - not equal to
    #   :ugt - unsigned greater than
    #   :uge - unsigned greater than or equal to
    #   :ult - unsigned less than
    #   :ule - unsigned less than or equal to
    #   :sgt - signed greater than
    #   :sge - signed greater than or equal to
    #   :slt - signed less than
    #   :sle - signed less than or equal to
    def icmp(pred, rhs)
      self.class.from_ptr(C.LLVMConstICmp(pred, self, rhs))
    end

    # Shift left.
    def <<(bits)
      self.class.from_ptr(C.LLVMConstShl(self, bits))
    end

    # Shift right.
    def >>(bits)
      self.class.from_ptr(C.LLVMConstLShr(self, bits))
    end

    # Arithmatic shift right.
    def ashr(bits)
      self.class.from_ptr(C.LLVMConstAShr(self, bits))
    end
  end

  def LLVM.const_missing(const)
    case const.to_s
    when /Int(\d+)/
      width = $1.to_i
      name  = "Int#{width}"
      eval <<-KLASS
        class #{name} < ConstantInt
          def self.type
            Type.from_ptr(C.LLVMIntType(#{width}))
          end
        end
      KLASS
      const_get(name)
    else
      super
    end
  end

  # Native integer type
  ::LLVM::Int = const_get("Int#{NATIVE_INT_SIZE}")

  # Creates a LLVM Int (subclass of ConstantInt) at the NATIVE_INT_SIZE from a integer (val).
  def LLVM.Int(val)
    case val
    when LLVM::ConstantInt then val
    when Integer then Int.from_i(val)
    end
  end

  class ConstantReal < Constant
    # Creates a ConstantReal from a float of Type.
    def self.from_f(n)
      from_ptr(C.LLVMConstReal(type, n))
    end

    def self.parse(type, str)
      from_ptr(C.LLVMConstRealOfString(type, str))
    end

    # Negation.
    def -@
      self.class.from_ptr(C.LLVMConstFNeg(self))
    end

    # Returns the result of adding this ConstantReal to rhs.
    def +(rhs)
      self.class.from_ptr(C.LLVMConstFAdd(self, rhs))
    end

    # Returns the result of multiplying this ConstantReal by rhs.
    def *(rhs)
      self.class.from_ptr(C.LLVMConstFMul(self, rhs))
    end

    # Returns the result of dividing this ConstantReal by rhs.
    def /(rhs)
      self.class.from_ptr(C.LLVMConstFDiv(self, rhs))
    end

    # Remainder.
    def rem(rhs)
      self.class.from_ptr(C.LLVMConstFRem(self, rhs))
    end

    # Floating point comparison using the predicate specified via the first
    # parameter. Predicate can be any of:
    #   :ord  - ordered
    #   :uno  - unordered: isnan(X) | isnan(Y)
    #   :oeq  - ordered and equal to
    #   :oeq  - unordered and equal to
    #   :one  - ordered and not equal to
    #   :one  - unordered and not equal to
    #   :ogt  - ordered and greater than
    #   :uge  - unordered and greater than or equal to
    #   :olt  - ordered and less than
    #   :ule  - unordered and less than or equal to
    #   :oge  - ordered and greater than or equal to
    #   :sge  - unordered and greater than or equal to
    #   :ole  - ordered and less than or equal to
    #   :sle  - unordered and less than or equal to
    #   :true - always true
    #   :false- always false
    def fcmp(pred, rhs)
      self.class.from_ptr(C.LLMVConstFCmp(pred, self, rhs))
    end
  end

  class Float < ConstantReal
    # Return a Type representation of the float.
    def self.type
      Type.from_ptr(C.LLVMFloatType)
    end
  end

  # Create a LLVM::Float from a Ruby Float (val).
  def LLVM.Float(val)
    Float.from_f(val)
  end

  class Double < ConstantReal
    def self.type
      Type.from_ptr(C.LLVMDoubleType)
    end
  end

  def LLVM.Double(val)
    Double.from_f(val)
  end

  class ConstantStruct < Constant
    # ConstantStruct.const(size) {|i| ... } or
    # ConstantStruct.const([...])
    def self.const(size_or_values, packed = false, &block)
      vals = LLVM::Support.allocate_pointers(size_or_values, &block)
      from_ptr C.LLVMConstStruct(vals, vals.size / vals.type_size, packed ? 1 : 0)
    end
  end

  class ConstantVector < Constant
    def self.all_ones
      from_ptr(C.LLVMConstAllOnes(type))
    end

    def self.const(size_or_values, &block)
      vals = LLVM::Support.allocate_pointers(size_or_values, &block)
      from_ptr(C.LLVMConstVector(vals, vals.size / vals.type_size))
    end
  end

  class GlobalValue < Constant
    def declaration?
      C.LLVMIsDeclaration(self)
    end

    def linkage
      C.LLVMGetLinkage(self)
    end

    def linkage=(linkage)
      C.LLVMSetLinkage(self, linkage)
    end

    def section
      C.LLVMGetSection(self)
    end

    def section=(section)
      C.LLVMSetSection(self, section)
    end

    def visibility
      C.LLVMGetVisibility(self)
    end

    def visibility=(viz)
      C.LLVMSetVisibility(self, viz)
    end

    def alignment
      C.LLVMGetAlignment(self)
    end

    def alignment=(bytes)
      C.LLVMSetAlignment(self, bytes)
    end

    def initializer
      Value.from_ptr(C.LLVMGetInitializer(self))
    end

    def initializer=(val)
      C.LLVMSetInitializer(self, val)
    end

    def global_constant?
      C.LLVMIsGlobalConstant(self)
    end

    def global_constant=(flag)
      C.LLVMSetGlobalConstant(self, flag)
    end
  end

  class Function < GlobalValue
    # Sets the function's calling convention and returns it.
    def call_conv=(conv)
      C.LLVMSetFunctionCallConv(self, conv)
      conv
    end

    # Adds the given attribute to the function.
    def add_attribute(attr)
      C.LLVMAddFunctionAttr(self, attr)
    end

    # Removes the given attribute from the function.
    def remove_attribute(attr)
      C.LLVMRemoveFunctionAttr(self, attr)
    end

    # Returns an Enumerable of the BasicBlocks in this function.
    def basic_blocks
      @basic_block_collection ||= BasicBlockCollection.new(self)
    end

    # @private
    class BasicBlockCollection
      include Enumerable

      def initialize(fun)
        @fun = fun
      end

      # Returns the number of BasicBlocks in the collection.
      def size
        C.LLVMCountBasicBlocks(@fun)
      end

      # Iterates through each BasicBlock in the collection.
      def each
        return to_enum :each unless block_given?

        ptr = C.LLVMGetFirstBasicBlock(@fun)
        0.upto(size-1) do |i|
          yield BasicBlock.from_ptr(ptr)
          ptr = C.LLVMGetNextBasicBlock(ptr)
        end

        self
      end

      # Adds a BasicBlock with the given name to the end of the collection.
      def append(name = "")
        BasicBlock.create(@fun, name)
      end

      # Returns the entry BasicBlock in the collection. This is the block the
      # function starts on.
      def entry
        BasicBlock.from_ptr(C.LLVMGetEntryBasicBlock(@fun))
      end

      # Returns the first BasicBlock in the collection.
      def first
        ptr = C.LLVMGetFirstBasicBlock(@fun)
        BasicBlock.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last BasicBlock in the collection.
      def last
        ptr = C.LLVMGetLastBasicBlock(@fun)
        BasicBlock.from_ptr(ptr) unless ptr.null?
      end
    end

    # Returns an Enumerable of the parameters in the function.
    def params
      @parameter_collection ||= ParameterCollection.new(self)
    end

    # @private
    class ParameterCollection
      def initialize(fun)
        @fun = fun
      end

      # Returns a Value representation of the parameter at the given index.
      def [](i)
        Value.from_ptr(C.LLVMGetParam(@fun, i))
      end

      # Returns the number of paramters in the collection.
      def size
        C.LLVMCountParams(@fun)
      end

      include Enumerable

      # Iteraters through each parameter in the collection.
      def each
        return to_enum :each unless block_given?
        0.upto(size-1) { |i| yield self[i] }
        self
      end
    end
  end

  class GlobalAlias < GlobalValue
  end

  class GlobalVariable < GlobalValue
    def initializer
      Value.from_ptr(C.LLVMGetInitializer(self))
    end

    def initializer=(val)
      C.LLVMSetInitializer(self, val)
    end

    def thread_local?
      case C.LLVMIsThreadLocal(self)
      when 0 then false
      else true
      end
    end

    def thread_local=(local)
      C.LLVMSetThreadLocal(self, local ? 1 : 0)
    end
  end

  class Instruction < User
    # Returns the parent of the instruction (a BasicBlock).
    def parent
      ptr = C.LLVMGetInstructionParent(self)
      LLVM::BasicBlock.from_ptr(ptr) unless ptr.null?
    end

    # Returns the next instruction after this one.
    def next
      ptr = C.LLVMGetNextInstruction(self)
      LLVM::Instruction.from_ptr(ptr) unless ptr.null?
    end

    # Returns the previous instruction before this one.
    def previous
      ptr = C.LLVMGetPreviousInstruction(self)
      LLVM::Instruction.from_ptr(ptr) unless ptr.null?
    end
  end

  class CallInst < Instruction
    # Sets the call convention to conv.
    def call_conv=(conv)
      C.LLVMSetInstructionCallConv(self, conv)
      conv
    end

    # Returns the call insatnce's call convention.
    def call_conv
      C.LLVMGetInstructionCallConv(self)
    end
  end

  class Phi < Instruction
    # Add incoming branches to a phi node by passing an alternating list of
    # resulting values and BasicBlocks. e.g.
    #   phi.add_incoming(val1, block1, val2, block2, ...)
    def add_incoming(*incoming)
      vals, blocks = [], []
      incoming.each_with_index do |node, i|
        (i % 2 == 0 ? vals : blocks) << node
      end

      unless vals.size == blocks.size
        raise ArgumentError, "Expected vals.size and blocks.size to match"
      end

      size = vals.size
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        FFI::MemoryPointer.new(FFI.type_size(:pointer) * size) do |blocks_ptr|
          blocks_ptr.write_array_of_pointer(blocks)
          C.LLVMAddIncoming(self, vals_ptr, blocks_ptr, vals.size)
        end
      end

      nil
    end
  end

  class SwitchInst < Instruction
    # Adds a case to a switch instruction. First the value to match on, then
    # the basic block.
    def add_case(val, block)
      C.LLVMAddCase(self, val, block)
    end
  end
end
