# frozen_string_literal: true
# typed: strict

module LLVM
  class Builder
    extend Gem::Deprecate

    # Important: Call #dispose to free backend memory after use.
    #: -> void
    def initialize
      @ptr = C.create_builder() #: FFI::Pointer?
      raise RuntimeError if @ptr.null? || ptr.nil?
    end

    #: FFI::Pointer?
    attr_reader :ptr

    #: -> void
    def dispose
      return if @ptr.nil?
      C.dispose_builder(@ptr)
      @ptr = nil
    end

    # @private
    #: -> FFI::Pointer?
    def to_ptr
      @ptr
    end

    # Position the builder at the given Instruction within the given BasicBlock.
    #
    # @param  [LLVM::BasicBlock]  block
    # @param  [LLVM::Instruction] instruction
    # @return [LLVM::Builder]
    #: (BasicBlock, Instruction) -> self
    def position(block, instruction)
      raise ArgumentError, "Block must be LLVM::BasicBlock" if !block.is_a?(LLVM::BasicBlock)

      raise ArgumentError, "Instruction must be LLVM::Instruction" if !instruction.is_a?(LLVM::Instruction)

      C.position_builder(self, block, instruction)
      self
    end

    # Positions the builder before the given Instruction.
    #
    # @param  [LLVM::Instruction] instruction
    # @return [LLVM::Builder]
    #: (Instruction) -> self
    def position_before(instruction)
      raise ArgumentError, "Instruction must be LLVM::Instruction" if !instruction.is_a?(LLVM::Instruction)

      C.position_builder_before(self, instruction)
      self
    end

    # Positions the builder at the end of the given BasicBlock.
    #
    # @param  [LLVM::BasicBlock] block
    # @return [LLVM::Builder]
    #: (BasicBlock) -> self
    def position_at_end(block)
      raise ArgumentError, "Block must be LLVM::BasicBlock" if !block.is_a?(LLVM::BasicBlock)

      C.position_builder_at_end(self, block)
      self
    end

    # The BasicBlock at which the Builder is currently positioned.
    #
    # @return [LLVM::BasicBlock]
    #: -> BasicBlock
    def insert_block
      BasicBlock.from_ptr(C.get_insert_block(self))
    end

    # @return [LLVM::Instruction]
    # @LLVMinst ret
    #: -> Value
    def ret_void
      Instruction.from_ptr(C.build_ret_void(self))
    end

    # @param [LLVM::Value] val The value to return
    # @return [LLVM::Instruction]
    # @LLVMinst ret
    #: (?Value?) -> Value
    def ret(val = nil)
      unless [LLVM::Value, NilClass].any? { |c| val.is_a?(c) }
        raise ArgumentError, "Trying to build LLVM ret with non-value: #{val.inspect}"
      end

      Instruction.from_ptr(C.build_ret(self, val))
    end

    # Builds a ret instruction returning multiple values.
    # @param [Array<LLVM::Value>] vals
    # @return [LLVM::Instruction]
    # @LLVMinst ret
    #: (*Value) -> Value
    def aggregate_ret(*vals)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * vals.size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        return Instruction.from_ptr(C.build_aggregate_ret(self, vals_ptr, vals.size))
      end #: as Value
    end

    # Unconditional branching (i.e. goto)
    # @param  [LLVM::BasicBlock]  block Where to jump
    # @return [LLVM::Instruction]
    # @LLVMinst br
    #: (BasicBlock) -> Value
    def br(block)
      raise ArgumentError, "Trying to build LLVM br with non-block: #{block.inspect}" if !block.is_a?(LLVM::BasicBlock)

      Instruction.from_ptr(C.build_br(self, block))
    end

    # Indirect branching (i.e. computed goto)
    # @param  [LLVM::BasicBlock]  addr      Where to jump
    # @param  [Integer]           num_dests Number of possible destinations to be added
    # @return [LLVM::Instruction]
    # @LLVMinst indirectbr
    #: (BasicBlock, Integer) -> Value
    def ibr(addr, num_dests)
      IndirectBr.from_ptr(
        C.build_indirect_br(self, addr, num_dests))
    end

    # Conditional branching (i.e. if)
    # @param  [LLVM::Value]       cond    The condition
    # @param  [LLVM::BasicBlock]  iftrue  Where to jump if condition is true
    # @param  [LLVM::BasicBlock]  iffalse Where to jump if condition is false
    # @return [LLVM::Instruction]
    # @LLVMinst br
    #: (Value, BasicBlock, BasicBlock) -> Value
    def cond(cond, iftrue, iffalse)
      raise ArgumentError, "Trying to build LLVM cond br with non-block (true branch): #{iftrue.inspect}" if !iftrue.is_a?(LLVM::BasicBlock)

      raise ArgumentError, "Trying to build LLVM cond br with non-block (false branch): #{iffalse.inspect}" if !iffalse.is_a?(LLVM::BasicBlock)

      cond2 = cond_condition(cond)

      Instruction.from_ptr(C.build_cond_br(self, cond2, iftrue, iffalse))
    end

    #: ((Value | bool)) -> Value
    private def cond_condition(cond)
      case cond
      when LLVM::Value
        cond_type = cond.type
        if (cond_type.kind != :integer) || (cond_type.width != 1)
          raise ArgumentError, "Trying to build LLVM cond br with non-i1 condition: #{cond_type}"
        end
        cond
      when true
        LLVM::Int1.from_i(1)
      when false
        LLVM::Int1.from_i(0)
      else
        raise ArgumentError, "Trying to build LLVM cond br with non-value condition: #{cond.inspect}"
      end
    end

    # @LLVMinst switch
    # @param [LLVM::Value] val The value to switch on
    # @param [LLVM::BasicBlock] default The default case
    # @param [Hash{LLVM::Value => LLVM::BasicBlock}] cases A Hash mapping
    #   values to basic blocks. When a value is matched, control will jump
    #   to the corresponding basic block.
    # @return [LLVM::Instruction]
    #: (Value, BasicBlock, Hash[Value, BasicBlock]) -> Value
    def switch(val, default, cases)
      inst = SwitchInst.from_ptr(C.build_switch(self, val, default, cases.size))
      cases.each do |(c, block)|
        inst.add_case(c, block)
      end
      inst
    end

    # Invoke a function which may potentially unwind
    # @param [LLVM::Function] fun The function to invoke
    # @param [Array<LLVM::Value>] args Arguments passed to fun
    # @param [LLVM::BasicBlock] normal Where to jump if fun does not unwind
    # @param [LLVM::BasicBlock] exception Where to jump if fun unwinds
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The value returned by 'fun', unless an
    #   unwind instruction occurs
    # @LLVMinst invoke
    #: (untyped, [Value], BasicBlock, BasicBlock, ?String) -> InvokeInst
    def invoke(fun, args, normal, exception, name = "")
      invoke2(nil, fun, args, normal, exception, name)
    end

    #: (Type?, untyped, [Value], BasicBlock, BasicBlock, ?String) -> InvokeInst
    def invoke2(type, fun, args, normal, exception, name = "")
      type, fun = call2_infer_function_and_type(type, fun)

      arg_count = args.size
      invoke_ins = nil #: InvokeInst?
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * arg_count) do |args_ptr|
        args_ptr.write_array_of_pointer(args)
        ins = C.build_invoke2(self, type, fun, args_ptr, arg_count, normal, exception, name)
        invoke_ins = InvokeInst.from_ptr(ins) #: as InvokeInst
      end

      if fun.is_a?(Function)
        invoke_ins.call_conv = fun.call_conv
      end

      invoke_ins #: as !nil
    end

    # @return LLVM::Value
    #: (Type, untyped, Integer, ?String) -> Value
    def landing_pad(type, personality_function, num_clauses, name = '')
      C.build_landing_pad(self, type, personality_function, num_clauses, name)
    end

    #: (Type, untyped, Integer, ?String) -> Value
    def landing_pad_cleanup(type, personality_function, num_clauses, name = '')
      lp = landing_pad(type, personality_function, num_clauses, name)
      C.set_cleanup(lp, 1)
      lp
    end

    # Builds an unwind Instruction.
    # @LLVMinst unwind
    #: -> void
    def unwind
      raise DeprecationError
    end

    # Generates an instruction with no defined semantics. Can be used to
    # provide hints to the optimizer.
    # @return [LLVM::Instruction]
    # @LLVMinst unreachable
    #: -> Value
    def unreachable
      Instruction.from_ptr(C.build_unreachable(self))
    end

    # Integer addition.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer sum of the two operands
    # @LLVMinst add
    #: (Value, Value, ?String) -> Value
    def add(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_add(self, lhs, rhs, name))
    end

    # "No signed wrap" integer addition.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer sum of the two operands
    # @LLVMinst add
    #: (Value, Value, ?String) -> Value
    def nsw_add(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nsw_add(self, lhs, rhs, name))
    end

    # "No unsigned wrap" integer addition.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer sum of the two operands
    # @LLVMinst add
    #: (Value, Value, ?String) -> Value
    def nuw_add(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nuw_add(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [LLVM::Value] rhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point sum of the two operands
    # @LLVMinst fadd
    #: (Value, Value, ?String) -> Value
    def fadd(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_add(self, lhs, rhs, name))
    end

    # Integer subtraction.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer difference of the two operands
    # @LLVMinst sub
    #: (Value, Value, ?String) -> Value
    def sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_sub(self, lhs, rhs, name))
    end

    # No signed wrap integer subtraction.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer difference of the two operands
    # @LLVMinst sub
    #: (Value, Value, ?String) -> Value
    def nsw_sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nsw_sub(self, lhs, rhs, name))
    end

    # No unsigned wrap integer subtraction.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer difference of the two operands
    # @LLVMinst sub
    #: (Value, Value, ?String) -> Value
    def nuw_sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nuw_sub(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [LLVM::Value] rhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point difference of the two
    #   operands
    # @LLVMinst fsub
    #: (Value, Value, ?String) -> Value
    def fsub(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_sub(self, lhs, rhs, name))
    end

    # Integer multiplication.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer product of the two operands
    # @LLVMinst mul
    #: (Value, Value, ?String) -> Value
    def mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_mul(self, lhs, rhs, name))
    end

    # "No signed wrap" integer multiplication.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer product of the two operands
    # @LLVMinst mul
    #: (Value, Value, ?String) -> Value
    def nsw_mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nsw_mul(self, lhs, rhs, name))
    end

    # "No unsigned wrap" integer multiplication.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer product of the two operands
    # @LLVMinst mul
    #: (Value, Value, ?String) -> Value
    def nuw_mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_nuw_mul(self, lhs, rhs, name))
    end

    # Floating point multiplication
    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [LLVM::Value] rhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point product of the two
    #   operands
    # @LLVMinst fmul
    #: (Value, Value, ?String) -> Value
    def fmul(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_mul(self, lhs, rhs, name))
    end

    # Unsigned integer division
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer quotient of the two operands
    # @LLVMinst udiv
    #: (Value, Value, ?String) -> Value
    def udiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_u_div(self, lhs, rhs, name))
    end

    # Signed division
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer quotient of the two operands
    # @LLVMinst sdiv
    #: (Value, Value, ?String) -> Value
    def sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_s_div(self, lhs, rhs, name))
    end

    # Signed exact division
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer quotient of the two operands
    # @LLVMinst sdiv
    #: (Value, Value, ?String) -> Value
    def exact_sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_exact_s_div(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [LLVM::Value] rhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point quotient of the two
    #   operands
    # @LLVMinst fdiv
    #: (Value, Value, ?String) -> Value
    def fdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_div(self, lhs, rhs, name))
    end

    # Unsigned remainder
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer remainder
    # @LLVMinst urem
    #: (Value, Value, ?String) -> Value
    def urem(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_u_rem(self, lhs, rhs, name))
    end

    # Signed remainder
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer remainder
    # @LLVMinst srem
    #: (Value, Value, ?String) -> Value
    def srem(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_s_rem(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [LLVM::Value] rhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point remainder
    # @LLVMinst frem
    #: (Value, Value, ?String) -> Value
    def frem(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_rem(self, lhs, rhs, name))
    end

    # The ‘fneg’ instruction returns the negation of its operand.
    # @param [LLVM::Value] lhs Floating point or vector of floating points
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The floating point negation
    # @LLVMinst fneg
    # https://llvm.org/docs/LangRef.html#fneg-instruction
    #: (Value, ?String) -> Value
    def fneg(lhs, name = "")
      Instruction.from_ptr(C.build_f_neg(self, lhs, name))
    end

    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst shl
    #: (Value, Value, ?String) -> Value
    def shl(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_shl(self, lhs, rhs, name))
    end

    # Shifts right with zero fill.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst lshr
    #: (Value, Value, ?String) -> Value
    def lshr(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_l_shr(self, lhs, rhs, name))
    end

    # Arithmatic shift right.
    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst ashr
    #: (Value, Value, ?String) -> Value
    def ashr(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_a_shr(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst and
    #: (Value, Value, ?String) -> Value
    def and(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_and(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst or
    #: (Value, Value, ?String) -> Value
    def or(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_or(self, lhs, rhs, name))
    end

    # @param [LLVM::Value] lhs Integer or vector of integers
    # @param [LLVM::Value] rhs Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer instruction
    # @LLVMinst xor
    #: (Value, Value, ?String) -> Value
    def xor(lhs, rhs, name = "")
      Instruction.from_ptr(C.build_xor(self, lhs, rhs, name))
    end

    # Integer negation. Implemented as a shortcut to the equivalent sub
    #   instruction.
    # @param [LLVM::Value] arg Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The negated operand
    # @LLVMinst sub
    #: (Value, ?String) -> Value
    def neg(arg, name = "")
      Instruction.from_ptr(C.build_neg(self, arg, name))
    end

    # "No signed wrap" integer negation.
    # @param [LLVM::Value] arg Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The negated operand
    # @LLVMinst sub
    #: (Value, ?String) -> Value
    def nsw_neg(arg, name = "")
      Instruction.from_ptr(C.build_nsw_neg(self, arg, name))
    end

    # "No unsigned wrap" integer negation.
    # @param [LLVM::Value] arg Integer or vector of integers
    # @param [String] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] The negated operand
    # @LLVMinst sub
    # @deprecated
    #: (Value, ?String) -> Value
    def nuw_neg(arg, name = "")
      Instruction.from_ptr(C.build_nuw_neg(self, arg, name))
    end
    deprecate :nuw_neg, "neg", 2025, 3

    # Boolean negation.
    # @param [LLVM::Value] arg Integer or vector of integers
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The negated operand
    #: (Value, ?String) -> Value
    def not(arg, name = "")
      Instruction.from_ptr(C.build_not(self, arg, name))
    end

    # @param [LLVM::Type, #type] ty The type or value whose type
    #   should be malloced
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A pointer to the malloced bytes
    #: (Type, ?String) -> Value
    def malloc(ty, name = "")
      Instruction.from_ptr(C.build_malloc(self, LLVM::Type(ty), name))
    end

    # @param [LLVM::Type, #type] ty The type or value whose type will be the
    #   element type of the malloced array
    # @param [LLVM::Value] sz Unsigned integer representing size of the array
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A pointer to the malloced array
    #: (Type, Integer, ?String) -> Value
    def array_malloc(ty, sz, name = "")
      size = case sz
      when LLVM::Value
        sz
      when Integer
        LLVM.i(32, sz)
      else
        raise ArgumentError, "Unknown size parameter for array_malloc: #{sz}"
      end
      Instruction.from_ptr(C.build_array_malloc(self, LLVM::Type(ty), size, name))
    end

    # Stack allocation.
    # @param [LLVM::Type, #type] ty The type or value whose type should be
    #   allocad
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A pointer to the allocad bytes
    # @LLVMinst alloca
    #: (Type, ?String) -> Alloca
    def alloca(ty, name = "")
      Alloca.from_ptr(C.build_alloca(self, LLVM::Type(ty), name)) #: as Alloca
    end

    # Array stack allocation
    # @param [LLVM::Type, #type] ty The type or value whose type will be the
    #   element type of the allocad array
    # @param [LLVM::Value] sz Unsigned integer representing size of the array
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A pointer to the allocad array
    # @LLVMinst alloca
    #: (Type, Integer, ?String) -> Alloca
    def array_alloca(ty, sz, name = "")
      Alloca.from_ptr(C.build_array_alloca(self, LLVM::Type(ty), sz, name)) #: as Alloca
    end

    # @param [LLVM::Value] ptr The pointer to be freed
    # @return [LLVM::Instruction] The result of the free instruction
    #: (Value) -> Value
    def free(ptr)
      Instruction.from_ptr(C.build_free(self, ptr))
    end

    # Load the value of a given pointer
    # @param [LLVM::Value] ptr The pointer to be loaded
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The result of the load operation. Represents
    #   a value of the pointer's type.
    # @LLVMinst load
    #: (Value, ?String) -> Value
    def load(ptr, name = "")
      load2(nil, ptr, name)
    end

    #: (Type?, Value, ?String) -> Value
    def load2(type, ptr, name = "")
      must_be_value!(ptr)

      type ||= infer_type(ptr)
      must_be_type!(type)

      load = C.build_load2(self, type, ptr, name)
      Instruction.from_ptr(load)
    end

    # Store a value at a given pointer
    # @param [LLVM::Value] val The value to be stored
    # @param [LLVM::Value] ptr A pointer to the same type as val
    # @return [LLVM::Instruction] The result of the store operation
    # @LLVMinst store
    #: (Value, Value) -> Value
    def store(val, ptr)
      raise "val must be a Value, got #{val.class.name}" unless Value === val
      Instruction.from_ptr(C.build_store(self, val, ptr))
    end

    # Obtain a pointer to the element at the given indices
    # @param [LLVM::Value] ptr A pointer to an aggregate value
    # @param [Array<LLVM::Value>] indices Ruby array of LLVM::Value representing
    #   indices into the aggregate
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The resulting pointer
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
    # may return Instruction or GlobalVariable
    #: (Value, [Value], ?String) -> Value
    def gep(ptr, indices, name = "")
      gep2(nil, ptr, indices, name)
    end

    # Obtain a pointer to the element at the given indices
    # @param [LLVM::Type] type An LLVM::Type
    # @param [LLVM::Value] ptr A pointer to an aggregate value
    # @param [Array<LLVM::Value>] indices Ruby array of LLVM::Value representing
    #   indices into the aggregate
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The resulting pointer
    # @LLVMinst gep2
    # @see http://llvm.org/docs/GetElementPtr.html
    # may return Instruction or GlobalVariable
    #: (Type?, Value, [Value], ?String) -> Value
    def gep2(type, ptr, indices, name = '')
      must_be_value!(ptr)

      type ||= must_infer_type!(ptr)
      must_be_type!(type)

      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        ins = C.build_gep2(self, type, ptr, indices_ptr, indices.size, name)
        return Instruction.from_ptr(ins)
      end #: as Value
    end

    # Builds a inbounds getelementptr instruction. If the indices are outside
    # the allocated pointer the value is undefined.
    # @param [LLVM::Value] ptr A pointer to an aggregate value
    # @param [Array<LLVM::Value>] indices Ruby array of LLVM::Value representing
    #   indices into the aggregate
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The resulting pointer
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
    #: (Value, [Value], ?String) -> Value
    def inbounds_gep(ptr, indices, name = "")
      inbounds_gep2(nil, ptr, indices, name)
    end

    #: (Type?, Value, [Value], ?String) -> Value
    def inbounds_gep2(type, ptr, indices, name = "")
      must_be_value!(ptr)

      type ||= must_infer_type!(ptr)
      must_be_type!(type)

      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        ins = C.build_inbounds_gep2(self, type, ptr, indices_ptr, indices.size, name)
        return Instruction.from_ptr(ins)
      end #: as Value
    end

    # Builds a struct getelementptr Instruction.
    #
    # @param  [LLVM::Value] ptr A pointer to a structure
    # @param  [LLVM::Value] idx     Unsigned integer representing the index of a
    #   structure member
    # @param  [String]      name    The name of the result in LLVM IR
    # @return [LLVM::Instruction]   The resulting pointer
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
    #: (Value, Value, ?String) -> Value
    def struct_gep(ptr, idx, name = "")
      struct_gep2(nil, ptr, idx, name)
    end

    #: (Type?, Value, Value, ?String) -> Value
    def struct_gep2(type, ptr, idx, name = "")
      must_be_value!(ptr)

      type ||= must_infer_type!(ptr)
      must_be_type!(type)

      ins = C.build_struct_gep2(self, type, ptr, idx.to_i, name)
      Instruction.from_ptr(ins)
    end

    # Creates a global string initialized to a given value.
    # @param [String] string The string used by the initialize
    # @param [Name] name Name of the result in LLVM IR
    # @return [LLVM::Instruction] Reference to the global string
    #: (String, ?String) -> Value
    def global_string(string, name = "")
      Instruction.from_ptr(C.build_global_string(self, string, name))
    end

    # Creates a pointer to a global string initialized to a given value.
    # @param [String] string The string used by the initializer
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] Reference to the global string pointer
    #: (String, ?String) -> Value
    def global_string_pointer(string, name = "")
      Instruction.from_ptr(C.build_global_string_ptr(self, string, name))
    end

    # Truncates its operand to the given type. The size of the value type must
    # be greater than the size of the target type.
    # @param [LLVM::Value] val Integer or vector of integers to be truncated
    # @param [LLVM::Type, #type] ty Integer or vector of integers of equal size
    #   to val
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The truncated value
    # @LLVMinst trunc
    #: (Value, Type, ?String) -> Value
    def trunc(val, ty, name = "")
      Instruction.from_ptr(C.build_trunc(self, val, LLVM::Type(ty), name))
    end

    # Zero extends its operand to the given type. The size of the value type
    # must be greater than the size of the target type.
    # @param [LLVM::Value] val Integer or vector of integers to be extended
    # @param [LLVM::Type, #type] ty Integer or vector of integer type of
    #   greater size than val
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The extended value
    # @LLVMinst zext
    #: (Value, Type, ?String) -> Value
    def zext(val, ty, name = "")
      Instruction.from_ptr(C.build_z_ext(self, val, LLVM::Type(ty), name))
    end

    # Sign extension by copying the sign bit (highest order bit) of the value
    # until it reaches the bit size of the given type.
    # @param [LLVM::Value] val Integer or vector of integers to be extended
    # @param [LLVM::Type] ty Integer or vector of integer type of greater size
    #   than the size of val
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The extended value
    # @LLVMinst sext
    #: (Value, Type, ?String) -> Value
    def sext(val, ty, name = "")
      Instruction.from_ptr(C.build_s_ext(self, val, LLVM::Type(ty), name))
    end

    # Convert a floating point to an unsigned integer
    # @param [LLVM::Value] val Floating point or vector of floating points to
    #   convert
    # @param [LLVM::Type, #type] ty Integer or vector of integer target type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The converted value
    # @LLVMinst fptoui
    #: (Value, Type, ?String) -> Value
    def fp2ui(val, ty, name = "")
      Instruction.from_ptr(C.build_fp_to_ui(self, val, LLVM::Type(ty), name))
    end

    # Convert a floating point to a signed integer
    # @param [LLVM::Value] val Floating point or vector of floating points to
    #   convert
    # @param [LLVM::Type, #type] ty Integer or vector of integer target type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The converted value
    # @LLVMinst fptosi
    #: (Value, Type, ?String) -> Value
    def fp2si(val, ty, name = "")
      Instruction.from_ptr(C.build_fp_to_si(self, val, LLVM::Type(ty), name))
    end

    # Convert an unsigned integer to a floating point
    # @param [LLVM::Value] val Unsigned integer or vector of unsigned integer
    #   to convert
    # @param [LLVM::Type, #type] ty Floating point or vector of floating point
    #   target type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The converted value
    # @LLVMinst uitofp
    #: (Value, Type, ?String) -> Value
    def ui2fp(val, ty, name = "")
      Instruction.from_ptr(C.build_ui_to_fp(self, val, LLVM::Type(ty), name))
    end

    # Convert a signed integer to a floating point
    # @param [LLVM::Value] val Signed integer or vector of signed integer
    #   to convert
    # @param [LLVM::Type, #type] ty Floating point or vector of floating point
    #   target type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The converted value
    # @LLVMinst sitofp
    #: (Value, Type, ?String) -> Value
    def si2fp(val, ty, name = "")
      Instruction.from_ptr(C.build_si_to_fp(self, val, LLVM::Type(ty), name))
    end

    # Truncate a floating point value
    # @param [LLVM::Value] val Floating point or vector of floating point
    # @param [LLVM::Type, #type] ty Floating point or vector of floating point
    #   type of lesser size than val's type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The truncated value
    # @LLVMinst fptrunc
    #: (Value, Type, ?String) -> Value
    def fp_trunc(val, ty, name = "")
      Instruction.from_ptr(C.build_fp_trunc(self, val, LLVM::Type(ty), name))
    end

    # Extend a floating point value
    # @param [LLVM::Value] val Floating point or vector of floating point
    # @param [LLVM::Type, #type] ty Floating point or vector of floating point
    #   type of greater size than val's type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The extended value
    # @LLVMinst fpext
    #: (Value, Type, ?String) -> Value
    def fp_ext(val, ty, name = "")
      Instruction.from_ptr(C.build_fp_ext(self, val, LLVM::Type(ty), name))
    end

    # Cast a pointer to an int. Useful for pointer arithmetic.
    # @param [LLVM::Value] val A pointer
    # @param [LLVM::Type, #type] ty An integer type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] An integer of the given type representing
    #   the pointer's address
    # @LLVMinst ptrtoint
    #: (Value, Type, ?String) -> Value
    def ptr2int(val, ty, name = "")
      Instruction.from_ptr(C.build_ptr_to_int(self, val, LLVM::Type(ty), name))
    end

    # Cast an int to a pointer
    # @param [LLVM::Value] val An integer value
    # @param [LLVM::Type, #ty] ty A pointer type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A pointer of the given type and the address
    #   held in val
    # @LLVMinst inttoptr
    #: (Value, Type, ?String) -> Value
    def int2ptr(val, ty, name = "")
      Instruction.from_ptr(C.build_int_to_ptr(self, val, LLVM::Type(ty), name))
    end

    # Cast a value to the given type without changing any bits
    # @param [LLVM::Value] val The value to cast
    # @param [LLVM::Type, #ty] ty The target type
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A value of the target type
    # @LLVMinst bitcast
    #: (Value, Type, ?String) -> Value
    def bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_bit_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    # @LLVMinst zext
    # @LLVMinst bitcast
    #: (Value, Type, ?String) -> Value
    def zext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_z_ext_or_bit_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    # @LLVMinst sext
    # @LLVMinst bitcast
    #: (Value, Type, ?String) -> Value
    def sext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_s_ext_or_bit_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    # @LLVMinst trunc
    # @LLVMinst bitcast
    #: (Value, Type, ?String) -> Value
    def trunc_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_trunc_or_bit_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    # Cast pointer to other type
    #: (Value, Type, ?String) -> Value
    def pointer_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_pointer_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    #: (Value, Type, ?String) -> Value
    def int_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_int_cast(self, val, LLVM::Type(ty), name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @param [bool] signed whether to sign or zero extend
    # @return [LLVM::Instruction]
    #: (Value, Type, bool, ?String) -> Value
    def int_cast2(val, ty, signed, name = "")
      Instruction.from_ptr(C.build_int_cast2(self, val, LLVM::Type(ty), signed, name))
    end

    # @param [LLVM::Value] val
    # @param [LLVM::Type, #ty] ty
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction]
    #: (Value, Type, ?String) -> Value
    def fp_cast(val, ty, name = "")
      Instruction.from_ptr(C.build_fp_cast(self, val, LLVM::Type(ty), name))
    end

    # Builds an icmp Instruction. Compares lhs to rhs (Instructions)
    # using the given symbol predicate (pred):
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
    # @param [Symbol] pred A predicate
    # @param [LLVM::Value] lhs The left hand side of the comparison, of integer
    #   or pointer type
    # @param [LLVM::Value] rhs The right hand side of the comparison, of the
    #   same type as lhs
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A boolean represented as i1
    # @LLVMinst icmp
    #: (Symbol, Value, Value, ?String) -> Value
    def icmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.build_i_cmp(self, pred, lhs, rhs, name))
    end

    # Builds an fcmp Instruction. Compares lhs to rhs (Instructions) as Reals
    # using the given symbol predicate (pred):
    #   :ord   - ordered
    #   :uno   - unordered: isnan(X) | isnan(Y)
    #   :oeq   - ordered and equal to
    #   :oeq   - unordered and equal to
    #   :one   - ordered and not equal to
    #   :one   - unordered and not equal to
    #   :ogt   - ordered and greater than
    #   :uge   - unordered and greater than or equal to
    #   :olt   - ordered and less than
    #   :ule   - unordered and less than or equal to
    #   :oge   - ordered and greater than or equal to
    #   :sge   - unordered and greater than or equal to
    #   :ole   - ordered and less than or equal to
    #   :sle   - unordered and less than or equal to
    #   :true  - always true and folded
    #   :false - always false and folded
    # @param [Symbol] pred A predicate
    # @param [LLVM::Value] lhs The left hand side of the comparison, of
    #   floating point type
    # @param [LLVM::Value] rhs The right hand side of the comparison, of
    #   the same type as lhs
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A boolean represented as i1
    # @LLVMinst fcmp
    #: (Symbol, Value, Value, ?String) -> Value
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.build_f_cmp(self, pred, lhs, rhs, name))
    end

    # Build a Phi node of the given type with the given incoming branches
    # @param [LLVM::Type] ty Specifies the result type
    # @param [Hash{LLVM::BasicBlock => LLVM::Value}] incoming A hash mapping
    #   basic blocks to a corresponding value. If the phi node is jumped to
    #   from a given basic block, the phi instruction takes on its
    #   corresponding value.
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The phi node
    # @LLVMinst phi
    #: (Type, Hash[BasicBlock, Value], ?String) -> Value
    def phi(ty, incoming, name = "")
      phi = Phi.from_ptr(C.build_phi(self, LLVM::Type(ty), name))
      phi.add_incoming(incoming)
      phi
    end

    # Builds a call Instruction. Calls the given Function with the given
    # args (Instructions).
    #
    # @param [LLVM::Function]     fun
    # @param [Array<LLVM::Value>] args
    # @param [LLVM::Instruction]
    # @LLVMinst call
    #: (untyped, *Value) -> CallInst
    def call(fun, *args)
      call2(
        nil,
        fun,
        *args #: untyped
      )
    end

    # TODO: (Type?, untyped) -> [Type, Function]
    #: (Type?, untyped) -> [untyped, untyped]
    private def call2_infer_function_and_type(type, fun)
      fun2 = fun.is_a?(LLVM::Value) ? fun : insert_block.parent.global_parent.functions[fun.to_s]

      msg = "Function provided to call instruction was neither a value nor a function name:"
      raise ArgumentError, "#{msg} #{fun}" if fun2.nil?

      msg = "Type must be provided to call2 when function argument is not a function type:"
      raise ArgumentError, "#{msg} #{fun}" if !fun2.is_a?(Function) && type.nil?

      type ||= fun2.function_type
      must_be_type!(type)

      [type, fun2]
    end

    #: (Type, untyped, *Value) -> CallInst
    def call2(type, fun, *args)
      type, fun = call2_infer_function_and_type(type, fun)

      name = if args.last.kind_of? String
        args.pop
      else
        ""
      end

      args_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size)
      args_ptr.write_array_of_pointer(args)
      ins = C.build_call2(self, type, fun, args_ptr, args.size, name)

      call_inst = CallInst.from_ptr(ins) #: as CallInst

      if fun.is_a?(Function)
        call_inst.call_conv = fun.call_conv
      end

      call_inst
    end

    # Return a value based on a condition. This differs from 'cond' in that
    # its operands are values rather than basic blocks. As a consequence, both
    # arguments must be evaluated.
    # @param [LLVM::Value] _if An i1 or a vector of i1
    # @param [LLVM::Value] _then A value or vector of the same arity as _if
    # @param [LLVM::Value] _else A value or vector of values of the same arity
    #   as _if, and of the same type as _then
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] An instruction representing either _then or
    #   _else
    # @LLVMinst select
    #: (Value, Value, Value, ?String) -> Value
    def select(_if, _then, _else, name = "")
      Instruction.from_ptr(C.build_select(self, _if, _then, _else, name))
    end

    # Extract an element from a vector
    # @param [LLVM::Value] vector The vector from which to extract a value
    # @param [LLVM::Value] idx The index of the element to extract, an
    #   unsigned integer
    # @param [String] name The value of the result in LLVM IR
    # @return [LLVM::Instruction] The extracted element
    # @LLVMinst extractelement
    #: (Value, Value, ?String) -> Value
    def extract_element(vector, idx, name = "")
      must_be_value!(vector)
      must_be_value!(idx)
      error = element_error(vector, idx)

      raise ArgumentError, "Error building extract_element with #{error}" if error

      ins = C.build_extract_element(self, vector, idx, name)
      Instruction.from_ptr(ins)
    end

    # Insert an element into a vector
    # @param [LLVM::Value] vector The vector into which to insert the element
    # @param [LLVM::Value] elem The element to be inserted into the vector
    # @param [LLVM::Value] idx The index at which to insert the element
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] A vector the same type as 'vector'
    # @LLVMinst insertelement
    #: (Value, Value, Value, ?String) -> Value
    def insert_element(vector, elem, idx, name = "")
      must_be_value!(vector)
      must_be_value!(elem)
      must_be_value!(idx)
      error = element_error(vector, idx)

      raise ArgumentError, "Error building insert_element with #{error}" if error

      ins = C.build_insert_element(self, vector, elem, idx, name)
      Instruction.from_ptr(ins)
    end

    # Shuffle two vectors according to a given mask
    # @param [LLVM::Value] vec1 A vector
    # @param [LLVM::Value] vec2 A vector of the same type and arity as vec1
    # @param [LLVM::Value] mask A vector of i1 of the same arity as vec1 and
    #   vec2
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The shuffled vector
    # @LLVMinst shufflevector
    #: (Value, Value, Value, ?String) -> Value
    def shuffle_vector(vec1, vec2, mask, name = "")
      Instruction.from_ptr(C.build_shuffle_vector(self, vec1, vec2, mask, name))
    end

    # Extract the value of a member field from an aggregate value
    # @param [LLVM::Value] aggregate An aggregate value
    # @param [Integer] idx The index of the member to extract
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The extracted value
    # @LLVMinst extractvalue
    #: (Value, Integer, ?String) -> Value
    def extract_value(aggregate, idx, name = "")
      must_be_value!(aggregate)
      error = value_error(aggregate, idx)

      raise ArgumentError, "Error building extract_value with #{error}" if error

      ins = C.build_extract_value(self, aggregate, idx, name)
      Instruction.from_ptr(ins)
    end

    # Insert a value into an aggregate value's member field
    # @param [LLVM::Value] aggregate An aggregate value
    # @param [LLVM::Value] elem The value to insert into 'aggregate'
    # @param [Integer] idx The index at which to insert the value
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] An aggregate value of the same type as 'aggregate'
    # @LLVMinst insertvalue
    #: (Value, Value, Integer, ?String) -> Value
    def insert_value(aggregate, elem, idx, name = "")
      must_be_value!(aggregate)
      must_be_value!(elem)
      error = value_error(aggregate, idx)

      raise ArgumentError, "Error building insert_value with #{error}" if error

      ins = C.build_insert_value(self, aggregate, elem, idx, name)
      Instruction.from_ptr(ins)
    end

    # Check if a value is null
    # @param [LLVM::Value] val The value to check
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] An i1
    # rubocop:disable Naming/PredicatePrefix
    #: (Value, ?String) -> Value
    def is_null(val, name = "")
      Instruction.from_ptr(C.build_is_null(self, val, name))
    end

    # Check if a value is not null
    # @param [LLVM::Value] val The value to check
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] An i1
    #: (Value, ?String) -> Value
    def is_not_null(val, name = "") # rubocop:disable Naming/PredicatePrefix
      Instruction.from_ptr(C.build_is_not_null(self, val, name))
    end

    # Calculate the difference between two pointers
    # @param [LLVM::Value] lhs A pointer
    # @param [LLVM::Value] rhs A pointer
    # @param [String] name The name of the result in LLVM IR
    # @return [LLVM::Instruction] The integer difference between the two
    #   pointers
    #: (Value, Value, ?String) -> Value
    def ptr_diff(lhs, rhs, name = "")
      ptr_diff2(nil, lhs, rhs, name)
    end

    #: (Type?, Value, Value, ?String) -> Value
    def ptr_diff2(type, lhs, rhs, name = "")
      must_be_value!(lhs)
      must_be_value!(rhs)

      type ||= begin
        lhs_type = must_infer_type!(lhs)
        rhs_type = must_infer_type!(lhs)
        raise ArgumentError, "ptr_diff types must match: [#{lhs_type}] [#{rhs_type}]" if lhs_type != rhs_type

        lhs_type
      end
      must_be_type!(type)

      Instruction.from_ptr(C.build_ptr_diff2(self, type, lhs, rhs, name))
    end

    private

    #: (untyped) -> void
    def must_be_value!(value)
      raise ArgumentError, "must be a Value, got #{value.class.name}" unless Value === value
    end

    #: (untyped) -> void
    def must_be_type!(type)
      type2 = LLVM.Type(type)
      raise ArgumentError, "must be a Type (LLVMTypeRef), got #{type2.class.name}" unless Type === type2
    end

    #: (untyped) -> void
    def must_infer_type!(value)
      infer_type(value)
    end

    #: (untyped) -> void
    def infer_type(ptr)
      case ptr
      when GlobalVariable
        Type.from_ptr(C.global_get_value_type(ptr))
      when Instruction
        must_infer_instruction_type!(ptr)
      else
        raise ArgumentError, "Cannot infer type from [#{ptr}] with type [#{ptr.type}]"
      end
    end

    #: (untyped) -> void
    def must_infer_instruction_type!(ptr)
      case ptr.opcode
      when :get_element_ptr
        must_infer_gep!(ptr)
      when :alloca
        ptr.allocated_type
      when :load
        ptr.type
      else
        raise "Inferring type for instruction not currently supported: #{ptr.opcode} #{ptr}"
      end
    end

    #: (untyped) -> void
    def must_infer_gep!(ptr)
      source_type = Type.from_ptr(C.get_gep_source_element_type(ptr))
      case source_type.kind
      when :integer
        source_type
      when :struct
        raise "Cannot currently infer type from gep of struct"
      when :array, :vector
        source_type.element_type
      else
        raise ArgumentError
      end
    end

    #: (untyped, Value) -> String?
    def element_error(vector, idx)
      if !vector.is_a?(LLVM::Value)
        # :nocov:
        # already handled
        "non-value: #{vector.inspect}"
        # :nocov:
      elsif vector.type.kind != :vector
        "non-vector: #{vector.type.kind}"
      elsif !idx.is_a?(LLVM::Value)
        # :nocov:
        # already handled
        "index: #{idx}"
        # :nocov:
      end
    end

    #: (untyped, Integer) -> String?
    def value_error(aggregate, idx)
      if !aggregate.is_a?(LLVM::Value)
        # :nocov:
        # already handled
        "non-value: #{aggregate.inspect}"
        # :nocov:
        # TODO: fix this
      elsif !aggregate.type.aggregate?
        "non-aggregate: #{aggregate.type.kind}"
      elsif !idx.is_a?(Integer) || idx.negative?
        "index: #{idx}"
      end
    end
  end
end
