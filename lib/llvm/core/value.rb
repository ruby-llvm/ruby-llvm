module LLVM
  class Value
    include PointerIdentity

    # @private
    def self.from_ptr(ptr)
      return if ptr.null?
      val = allocate
      val.instance_variable_set(:@ptr, ptr)
      val
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
      Type.from_ptr(C.type_of(self), nil)
    end

    # Returns the value's name.
    def name
      C.get_value_name(self)
    end

    # Sets the value's name to str.
    def name=(str)
      C.set_value_name(self, str)
      str
    end

    # Print the value's IR to stdout.
    def dump
      C.dump_value(self)
    end

    # Returns whether the value is constant.
    def constant?
      case C.is_constant(self)
      when 0 then false
      when 1 then true
      end
    end

    # Returns whether the value is null.
    def null?
      case C.is_null(self)
      when 0 then false
      when 1 then true
      end
    end

    # Returns whether the value is undefined.
    def undefined?
      case C.is_undef(self)
      when 0 then false
      when 1 then true
      end
    end

    # Adds attr to this value's attributes.
    def add_attribute(attr)
      C.add_attribute(self, attr)
    end
  end

  class Argument < Value
  end

  class BasicBlock < Value
    # Creates a basic block for the given function with the given name.
    def self.create(fun = nil, name = "")
      self.from_ptr(C.append_basic_block(fun, name))
    end

    # Build the basic block with the given builder. Creates a new one if nil. Yields the builder.
    def build(builder = nil)
      if builder.nil?
        builder = Builder.new
        builder.position_at_end(self)
        yield builder
        builder.dispose
      else
        builder.position_at_end(self)
        yield builder
      end
    end

    # Returns the parent of this basic block (a Function).
    def parent
      fp = C.get_basic_block_parent(self)
      LLVM::Function.from_ptr(fp) unless fp.null?
    end

    # Returns the next basic block in the sequence.
    def next
      ptr = C.get_next_basic_block(self)
      BasicBlock.from_ptr(ptr) unless ptr.null?
    end

    # Returns the previous basic block in the sequence.
    def previous
      ptr = C.get_previous_basic_block(self)
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
        ptr = C.get_first_instruction(@block)
        LLVM::Instruction.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last Instruction in the collection.
      def last
        ptr = C.get_last_instruction(@block)
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
        ptr = C.get_operand(@user, i)
        Value.from_ptr(ptr) unless ptr.null?
      end

      # Set or replace an operand by index.
      def []=(i, v)
        C.set_operand(@user, i, v)
      end

      # Returns the number of operands in the collection.
      def size
        C.get_num_operands(@user)
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
      from_ptr(C.const_null(type))
    end

    # Creates a undefined constant of Type.
    def self.undef(type)
      from_ptr(C.get_undef(type))
    end

    # Creates a null pointer constant of Type.
    def self.null_ptr(type)
      from_ptr(C.const_pointer_null(type))
    end

    # Bitcast this constant to Type.
    def bitcast_to(type)
      ConstantExpr.from_ptr(C.const_bit_cast(self, type))
    end

    # Returns the element pointer at the given indices of the constant.
    # For more information on gep go to: http://llvm.org/docs/GetElementPtr.html
    def gep(*indices)
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return ConstantExpr.from_ptr(
          C.const_gep(self, indices_ptr, indices.size))
      end
    end

    def bit_cast(type)
      return ConstantExpr.from_ptr(C.const_bit_cast(self, type))
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
      from_ptr(C.const_string(str, str.length, null_terminate ? 0 : 1))
    end

    # ConstantArray.const(type, 3) {|i| ... } or
    # ConstantArray.const(type, [...])
    def self.const(type, size_or_values, &block)
      vals = LLVM::Support.allocate_pointers(size_or_values, &block)
      from_ptr C.const_array(type, vals, vals.size / vals.type_size)
    end

    def size
      C.get_array_length(type)
    end
  end

  class ConstantExpr < Constant
  end

  class ConstantInt < Constant
    def self.all_ones
      from_ptr(C.const_all_ones(type))
    end

    # Creates a ConstantInt from an integer.
    def self.from_i(n, signed = true)
      from_ptr(C.const_int(type, n, signed ? 1 : 0))
    end

    def self.parse(str, radix = 10)
      from_ptr(C.const_int_of_string(type, str, radix))
    end

    # Negation.
    def -@
      self.class.from_ptr(C.const_neg(self))
    end

    alias neg -@

    # "No signed wrap" negation.
    def nsw_neg
      self.class.from_ptr(C.const_nsw_neg(self))
    end

    # "No unsigned wrap" negation.
    def nuw_neg
      self.class.from_ptr(C.const_nuw_neg(self))
    end

    # Addition.
    def +(rhs)
      self.class.from_ptr(C.const_add(self, rhs))
    end

    alias add +

    # "No signed wrap" addition.
    def nsw_add(rhs)
      self.class.from_ptr(C.const_nsw_add(self, rhs))
    end

    # "No unsigned wrap" addition.
    def nuw_add(rhs)
      self.class.from_ptr(C.const_nuw_add(self, rhs))
    end

    # Subtraction.
    def -(rhs)
      self.class.from_ptr(C.const_sub(self, rhs))
    end

    alias sub -

    # "No signed wrap" subtraction.
    def nsw_sub(rhs)
      self.class.from_ptr(C.const_nsw_sub(self, rhs))
    end

    # "No unsigned wrap" subtraction.
    def nuw_sub(rhs)
      self.class.from_ptr(C.const_nuw_sub(self, rhs))
    end

    # Multiplication.
    def *(rhs)
      self.class.from_ptr(C.const_mul(self, rhs))
    end

    alias mul *

    # "No signed wrap" multiplication.
    def nsw_mul(rhs)
      self.class.from_ptr(C.const_nsw_mul(self, rhs))
    end

    # "No unsigned wrap" multiplication.
    def nuw_mul(rhs)
      self.class.from_ptr(C.const_nuw_mul(self, rhs))
    end

    # Unsigned division.
    def udiv(rhs)
      self.class.from_ptr(C.const_u_div(self, rhs))
    end

    # Signed division.
    def /(rhs)
      self.class.from_ptr(C.const_s_div(self, rhs))
    end

    # Unsigned remainder.
    def urem(rhs)
      self.class.from_ptr(C.const_u_rem(self, rhs))
    end

    # Signed remainder.
    def rem(rhs)
      self.class.from_ptr(C.const_s_rem(self, rhs))
    end

    # Boolean negation.
    def ~@
      self.class.from_ptr(C.const_not(self))
    end

    alias not ~

    # Integer AND.
    def &(rhs)
      self.class.from_ptr(C.const_and(self, rhs))
    end

    alias and &

    # Integer OR.
    def |(rhs)
      self.class.from_ptr(C.const_or(self, rhs))
    end

    alias or |

    # Integer XOR.
    def ^(rhs)
      self.class.from_ptr(C.const_xor(self, rhs))
    end

    alias xor ^

    # Shift left.
    def <<(bits)
      self.class.from_ptr(C.const_shl(self, bits))
    end

    alias shl <<

    # Shift right.
    def >>(bits)
      self.class.from_ptr(C.const_l_shr(self, bits))
    end

    alias shr >>

    # Arithmatic shift right.
    def ashr(bits)
      self.class.from_ptr(C.const_a_shr(self, bits))
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
      self.class.from_ptr(C.const_i_cmp(pred, self, rhs))
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
            Type.from_ptr(C.int_type(#{width}), :integer)
          end
        end
      KLASS
      const_get(name)
    else
      super
    end
  end

  # Native integer type
  bits = FFI.type_size(:int) * 8
  ::LLVM::Int = const_get("Int#{bits}")

  # Creates a LLVM Int (subclass of ConstantInt) at the NATIVE_INT_SIZE from a integer (val).
  def LLVM.Int(val)
    case val
    when LLVM::ConstantInt then val
    when Integer then Int.from_i(val)
    when Value
      return val if val.type.kind == :integer
      raise "value not of integer type: #{val.type.kind}"
    else raise "can't make an LLVM::ConstantInt from #{val.class.name}"
    end
  end

  # Boolean values
  ::LLVM::TRUE = ::LLVM::Int1.from_i(-1)
  ::LLVM::FALSE = ::LLVM::Int1.from_i(0)

  class ConstantReal < Constant
    # Creates a ConstantReal from a float of Type.
    def self.from_f(n)
      from_ptr(C.const_real(type, n))
    end

    def self.parse(type, str)
      from_ptr(C.const_real_of_string(type, str))
    end

    # Negation.
    def -@
      self.class.from_ptr(C.const_f_neg(self))
    end

    # Returns the result of adding this ConstantReal to rhs.
    def +(rhs)
      self.class.from_ptr(C.const_f_add(self, rhs))
    end

    # Returns the result of multiplying this ConstantReal by rhs.
    def *(rhs)
      self.class.from_ptr(C.const_f_mul(self, rhs))
    end

    # Returns the result of dividing this ConstantReal by rhs.
    def /(rhs)
      self.class.from_ptr(C.const_f_div(self, rhs))
    end

    # Remainder.
    def rem(rhs)
      self.class.from_ptr(C.const_f_rem(self, rhs))
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
      self.class.from_ptr(C.llmv_const_f_cmp(pred, self, rhs))
    end
  end

  class Float < ConstantReal
    # Return a Type representation of the float.
    def self.type
      Type.from_ptr(C.float_type, :float)
    end
  end

  # Create a LLVM::Float from a Ruby Float (val).
  def LLVM.Float(val)
    Float.from_f(val)
  end

  class Double < ConstantReal
    def self.type
      Type.from_ptr(C.double_type, :double)
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
      from_ptr C.const_struct(vals, vals.size / vals.type_size, packed ? 1 : 0)
    end
  end

  class ConstantVector < Constant
    def self.all_ones
      from_ptr(C.const_all_ones(type))
    end

    def self.const(size_or_values, &block)
      vals = LLVM::Support.allocate_pointers(size_or_values, &block)
      from_ptr(C.const_vector(vals, vals.size / vals.type_size))
    end

    def size
      C.get_vector_size(type)
    end
  end

  class GlobalValue < Constant
    def declaration?
      C.is_declaration(self)
    end

    def linkage
      C.get_linkage(self)
    end

    def linkage=(linkage)
      C.set_linkage(self, linkage)
    end

    def section
      C.get_section(self)
    end

    def section=(section)
      C.set_section(self, section)
    end

    def visibility
      C.get_visibility(self)
    end

    def visibility=(viz)
      C.set_visibility(self, viz)
    end

    def alignment
      C.get_alignment(self)
    end

    def alignment=(bytes)
      C.set_alignment(self, bytes)
    end

    def initializer
      Value.from_ptr(C.get_initializer(self))
    end

    def initializer=(val)
      C.set_initializer(self, val)
    end

    def global_constant?
      C.is_global_constant(self)
    end

    def global_constant=(flag)
      C.set_global_constant(self, flag)
    end

    def unnamed_addr?
      Support::C.has_unnamed_addr(self) != 0
    end

    def unnamed_addr=(flag)
      Support::C.set_unnamed_addr(self, flag ? 1 : 0)
    end
  end

  class Function < GlobalValue
    # Sets the function's calling convention and returns it.
    def call_conv=(conv)
      C.set_function_call_conv(self, conv)
      conv
    end

    # Adds the given attribute to the function.
    def add_attribute(attr)
      C.add_function_attr(self, attr)
    end

    # Removes the given attribute from the function.
    def remove_attribute(attr)
      C.remove_function_attr(self, attr)
    end

    # Returns an Enumerable of the BasicBlocks in this function.
    def basic_blocks
      @basic_block_collection ||= BasicBlockCollection.new(self)
    end

    def type
      Type.from_ptr(C.type_of(self), :function)
    end

    # @private
    class BasicBlockCollection
      include Enumerable

      def initialize(fun)
        @fun = fun
      end

      # Returns the number of BasicBlocks in the collection.
      def size
        C.count_basic_blocks(@fun)
      end

      # Iterates through each BasicBlock in the collection.
      def each
        return to_enum :each unless block_given?

        ptr = C.get_first_basic_block(@fun)
        0.upto(size-1) do |i|
          yield BasicBlock.from_ptr(ptr)
          ptr = C.get_next_basic_block(ptr)
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
        BasicBlock.from_ptr(C.get_entry_basic_block(@fun))
      end

      # Returns the first BasicBlock in the collection.
      def first
        ptr = C.get_first_basic_block(@fun)
        BasicBlock.from_ptr(ptr) unless ptr.null?
      end

      # Returns the last BasicBlock in the collection.
      def last
        ptr = C.get_last_basic_block(@fun)
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
        sz = self.size
        i = sz + i if i < 0
        return unless 0 <= i && i < sz
        Value.from_ptr(C.get_param(@fun, i))
      end

      # Returns the number of paramters in the collection.
      def size
        C.count_params(@fun)
      end

      include Enumerable

      # Iteraters through each parameter in the collection.
      def each
        return to_enum :each unless block_given?
        0.upto(size-1) { |i| yield self[i] }
        self
      end
    end

    def gc=(name)
      C.set_gc(self, name)
    end
    def gc
      C.get_gc(self)
    end
  end

  class GlobalAlias < GlobalValue
  end

  class GlobalVariable < GlobalValue
    def initializer
      Value.from_ptr(C.get_initializer(self))
    end

    def initializer=(val)
      C.set_initializer(self, val)
    end

    def thread_local?
      case C.is_thread_local(self)
      when 0 then false
      else true
      end
    end

    def thread_local=(local)
      C.set_thread_local(self, local ? 1 : 0)
    end
  end

  class Instruction < User
    # Returns the parent of the instruction (a BasicBlock).
    def parent
      ptr = C.get_instruction_parent(self)
      LLVM::BasicBlock.from_ptr(ptr) unless ptr.null?
    end

    # Returns the next instruction after this one.
    def next
      ptr = C.get_next_instruction(self)
      LLVM::Instruction.from_ptr(ptr) unless ptr.null?
    end

    # Returns the previous instruction before this one.
    def previous
      ptr = C.get_previous_instruction(self)
      LLVM::Instruction.from_ptr(ptr) unless ptr.null?
    end
  end

  class CallInst < Instruction
    # Sets the call convention to conv.
    def call_conv=(conv)
      C.set_instruction_call_conv(self, conv)
      conv
    end

    # Returns the call insatnce's call convention.
    def call_conv
      C.get_instruction_call_conv(self)
    end
  end

  # @private
  class Phi < Instruction
    # Add incoming branches to a phi node by passing an alternating list of
    # resulting values and BasicBlocks. e.g.
    #   phi.add_incoming(val1, block1, val2, block2, ...)
    def add_incoming(incoming)
      blks = incoming.keys
      vals = incoming.values_at(*blks)
      size = incoming.size

      FFI::MemoryPointer.new(FFI.type_size(:pointer) * size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        FFI::MemoryPointer.new(FFI.type_size(:pointer) * size) do |blks_ptr|
          blks_ptr.write_array_of_pointer(blks)
          C.add_incoming(self, vals_ptr, blks_ptr, vals.size)
        end
      end

      nil
    end
  end

  # @private
  class SwitchInst < Instruction
    # Adds a case to a switch instruction. First the value to match on, then
    # the basic block.
    def add_case(val, block)
      C.add_case(self, val, block)
    end
  end


  # @private
  class IndirectBr < Instruction
    # Adds a basic block reference as a destination for this indirect branch.
    def add_dest(dest)
      C.add_destination(self, dest)
    end

    alias :<< :add_dest
  end
end
