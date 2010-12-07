module LLVM
  class Value
    def self.from_ptr(ptr)
      new(ptr) unless ptr.null?
    end
    
    class << self
      private :new
    end
    
    def initialize(ptr)
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.type
      raise NotImplementedError, "Value.type is abstract"
    end
    
    def self.to_ptr
      type.to_ptr
    end
    
    def type
      Type.from_ptr(C.LLVMTypeOf(self))
    end
    
    def name
      C.LLVMGetValueName(self)
    end
    
    def name=(str)
      C.LLVMSetValueName(self, str)
      str
    end
    
    def dump
      C.LLVMDumpValue(self)
    end
    
    def constant?
      case C.LLVMIsConstant(self)
      when 0 then false
      when 1 then true
      end
    end
    
    def null?
      case C.LLVMIsNull(self)
      when 0 then false
      when 1 then true
      end
    end
    
    def undefined?
      case C.LLVMIsUndef(self)
      when 0 then false
      when 1 then true
      end
    end
    
    def add_attribute(attr)
      C.LLVMAddAttribute(self, attr)
    end
  end
  
  class Argument < Value
  end
  
  class BasicBlock < Value
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
      builder.dispose
    end
  end
  
  class Constant < Value
    def self.type
      raise NotImplementedError, "Constant.type() is abstract."
    end
    
    def self.null
      from_ptr(C.LLVMConstNull(type))
    end
    
    def self.undef
      from_ptr(C.LLVMGetUndef(type))
    end
    
    def self.null_ptr
      from_ptr(C.LLVMConstPointerNull(type))
    end
  end
  
  class ConstantArray < Constant
    def self.string(str, null_terminate = true)
      from_ptr(C.LLVMConstString(str, null_terminate ? 0 : 1))
    end
    
    def self.const(type, size)
      vals = (0...size).map { |i| yield i }
      from_ptr C.LLVMConstArray(type, vals, size)
    end
  end
  
  class ConstantExpr < Constant
  end
  
  class ConstantInt < Constant
    def self.all_ones
      from_ptr(C.LLVMConstAllOnes(type))
    end
    
    def self.from_i(n, signed = true)
      from_ptr(C.LLVMConstInt(type, n, signed ? 1 : 0))
    end
    
    def self.parse(str, radix = 10)
      from_ptr(C.LLVMConstIntOfString(type, str, radix))
    end
    
    def -@
      self.class.from_ptr(C.LLVMConstNeg(self))
    end
    
    def not
      self.class.from_ptr(C.LLVMConstNot(self))
    end
    
    def +(rhs)
      self.class.from_ptr(C.LLVMConstAdd(self, rhs))
    end
    
    def nsw_add(rhs)
      self.class.from_ptr(C.LLVMConstNSWAdd(self, rhs))
    end
    
    def *(rhs)
      self.class.from_ptr(C.LLVMConstMul(self, rhs))
    end
    
    def udiv(rhs)
      self.class.from_ptr(C.LLVMConstUDiv(self, rhs))
    end
    
    def /(rhs)
      self.class.from_ptr(C.LLVMConstSDiv(self, rhs))
    end
    
    def urem(rhs)
      self.class.from_ptr(C.LLVMConstURem(self, rhs))
    end
    
    def rem(rhs)
      self.class.from_ptr(C.LLVMConstSRem(self, rhs))
    end
    
    def and(rhs) # Ruby's && cannot be overloaded
      self.class.from_ptr(C.LLVMConstAnd(self, rhs))
    end
    
    def or(rhs) # Nor is ||.
      self.class.from_ptr(C.LLVMConstOr(self, rhs))
    end
    
    def xor(rhs) # Nor is ||.
      self.class.from_ptr(C.LLVMConstXor(self, rhs))
    end
    
    def icmp(pred, rhs)
      self.class.from_ptr(C.LLVMConstICmp(pred, self, rhs))
    end
    
    def <<(bits)
      self.class.from_ptr(C.LLVMConstShl(self, rhs))
    end
    
    def >>(bits)
      self.class.from_ptr(C.LLVMConstLShr(self, rhs))
    end
    
    def ashr(bits)
      self.class.from_ptr(C.LLVMConstAShr(self, rhs))
    end
  end
  
  def LLVM.const_missing(const) # :nodoc:
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
  
  def LLVM.Int(val)
    case val
    when LLVM::ConstantInt then val
    when Integer then Int.from_i(val)
    end
  end
  
  class ConstantReal < Constant
    def self.from_f(n)
      from_ptr(C.LLVMConstReal(type, n))
    end
    
    def self.parse(str)
      from_ptr(C.LLVMConstRealOfString(type, str))
    end
    
    def -@
      self.class.from_ptr(C.LLVMConstFNeg(self))
    end
    
    def +(rhs)
      self.class.from_ptr(C.LLVMConstFAdd(self, rhs))
    end
    
    def *(rhs)
      self.class.from_ptr(C.LLVMConstFMul(self, rhs))
    end
    
    def /(rhs)
      self.class.from_ptr(C.LLVMConstFDiv(self, rhs))
    end
    
    def rem(rhs)
      self.class.from_ptr(C.LLVMConstFRem(self, rhs))
    end
    
    def fcmp(pred, rhs)
      self.class.from_ptr(C.LLMVConstFCmp(pred, self, rhs))
    end
  end
  
  class Float < ConstantReal
    def self.type
      Type.from_ptr(C.LLVMFloatType)
    end
  end
  
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
    def self.const(size, packed = false)
      vals = (0..size).map { |i| yield i }
      from_ptr(C.LLVMConstStruct(vals, size, packed ? 1 : 0))
    end
  end
  
  class ConstantVector < Constant
    def self.all_ones
      from_ptr(C.LLVMConstAllOnes(type))
    end
    
    def self.const(size)
      vals = (0..size).map { |i| yield i }
      from_ptr(C.LLVMConstVector(vals, size))
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
  end
  
  class Function < GlobalValue
    def call_conv=(conv)
      C.LLVMSetFunctionCallConv(self, conv)
      conv
    end
    
    def add_attribute(attr)
      C.LLVMAddFunctionAttr(self, attr)
    end
    
    def remove_attribute(attr)
      C.LLVMRemoveFunctionAttr(self, attr)
    end
    
    def basic_blocks
      @basic_block_collection ||= BasicBlockCollection.new(self)
    end
    
    class BasicBlockCollection
      def initialize(fun)
        @fun = fun
      end
      
      def size
        C.LLVMCountBasicBlocks(@fun)
      end
      
      def append(name = "")
        BasicBlock.from_ptr(C.LLVMAppendBasicBlock(@fun, name))
      end
      
      def entry
        BasicBlock.from_ptr(C.LLVMGetEntryBasicBlock(@fun))
      end
    end
    
    def params
      @parameter_collection ||= ParameterCollection.new(self)
    end
    
    class ParameterCollection
      include Enumerable

      def initialize(fun)
        @fun = fun
      end
      
      def each
        return Enumerator.new(self) unless block_given?
        n = size
        0.upto(n-1) {|i| yield self[i] }
        self
      end

      def [](i)
        Value.from_ptr(C.LLVMGetParam(@fun, i))
      end
      
      def size
        C.LLVMCountParams(@fun)
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
  
  class Instruction < Value
  end
  
  class CallInst < Instruction
    def call_conv=(conv)
      C.LLVMSetInstructionCallConv(self, conv)
      conv
    end
    
    def call_conv
      C.LLVMGetInstructionCallConv(self)
    end
  end
  
  class Phi < Instruction
    # Add incoming branches to a phi node by passing an alternating list
    # of resulting values and basic blocks. e.g.
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
    # Adds a case to a switch instruction. First the value to match on,
    # then the basic block.
    def add_case(val, block)
      C.LLVMAddCase(self, val, block)
    end
  end
end
