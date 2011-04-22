module LLVM
  class Builder
    private_class_method :new

    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end

    def to_ptr # :nodoc:
      @ptr
    end

    # Creates a Builder.
    def self.create
      new(C.LLVMCreateBuilder())
    end

    # Positions the builder at the given Instruction in the given BasicBlock.
    def position(block, instruction)
      raise "Block must not be nil" if block.nil?
      C.LLVMPositionBuilder(self, block, instruction)
      self
    end

    # Positions the builder before the given Instruction.
    def position_before(instruction)
      raise "Instruction must not be nil" if instruction.nil?
      C.LLVMPositionBuilderBefore(self, instruction)
      self
    end

    # Positions the builder at the end of the given BasicBlock.
    def position_at_end(block)
      raise "Block must not be nil" if block.nil?
      C.LLVMPositionBuilderAtEnd(self, block)
      self
    end

    # The BasicBlock at which the Builder is currently positioned.
    def insert_block
      BasicBlock.from_ptr(C.LLVMGetInsertBlock(self))
    end


    # Builds a void return Instruction.
    def ret_void
      Instruction.from_ptr(C.LLVMBuildRetVoid(self))
    end

    # Builds a return Instruction that returns the given Value.
    def ret(val)
      Instruction.from_ptr(C.LLVMBuildRet(self, val))
    end

    # Buidls a aggregated return Instruction that returns the given array of
    # Values.
    def aggregate_ret(*vals)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * vals.size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        Instruction.from_ptr(C.LLVMBuildAggregateRet(self, vals_ptr, vals.size))
      end
    end

    # Builds a branch Instruction that jumps the program to the given
    # BasicBlock.
    def br(block)
      Instruction.from_ptr(
        C.LLVMBuildBr(self, block))
    end

    # Builds a condition branch Instruction. cond is an Value, and
    # iftrue and iffalse are BasicBlocks.
    def cond(cond, iftrue, iffalse)
      Instruction.from_ptr(
        C.LLVMBuildCondBr(self, cond, iftrue, iffalse))
    end

    # Builds a switch Instruction. Creates a SwitchInst that checks val by
    # a specific number of given cases. default is a BasicBlock, and
    # represents the default case in the switch statement.
    def switch(val, default, ncases)
      SwitchInst.from_ptr(C.LLVMBuildSwitch(self, val, default, ncases))
    end

    # Builds an invoke Instruction with the given name. It invokes the given
    # Function with the given args and branches depending on the result. If
    # the called function returns with an unwind instruction, control
    # is transferred to the _catch block, and if it returns with a ret
    # instruction, control is transferred to the _then block.
    def invoke(fun, args, _then, _catch, name = "")
      Instruction.from_ptr(
        C.LLVMBuildInvoke(self,
          fun, args, args.size, _then, _catch, name))
    end

    # Builds an unwind Instruction.
    def unwind
      Instruction.from_ptr(C.LLVMBuildUnwind(self))
    end

    # Builds an unreachable Instruction.
    def unreachable
      Instruction.from_ptr(C.LLVMBuildUnreachable(self))
    end

    # Builds an add Instruction with the given name. Adds the given lhs and rhs.
    def add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAdd(self, lhs, rhs, name))
    end

    # No signed wrap addition.
    def nsw_add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildNSWAdd(self, lhs, rhs, name))
    end

    # Builds an fadd Instruction with the given name. Adds the given lhs and rhs as Floats.
    def fadd(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFAdd(self, lhs, rhs, name))
    end

    # Builds an sub Instruction with the given name. Subtracts the given rhs from lhs.
    def sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSub(self, lhs, rhs, name))
    end

    # Builds an fsub Instruction with the given name. Subtracts the given rhs from lhs as floats.
    def fsub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFSub(self, lhs, rhs, name))
    end

    # Builds an mul Instruction with the given name. Multiplies the given lhs by rhs.
    def mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildMul(self, lhs, rhs, name))
    end

    # Builds an mul Instruction with the given name. Multiplies the given lhs by rhs as floats.
    def fmul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFMul(self, lhs, rhs, name))
    end

    # Builds an udiv Instruction with the given name. Divides the given lhs by rhs. Unsigned.
    def udiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildUDiv(self, lhs, rhs, name))
    end

    # Builds an sdiv Instruction with the given name. Divides the given lhs by rhs. Signed.
    def sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSDiv(self, lhs, rhs, name))
    end

    # Builds an exact_sdiv Instruction with the given name. Divides the given lhs by rhs if it can be
    # determined and if the remainder is known to be zero. Signed.
    def exact_sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildExactSDiv(self, lhs, rhs, name))
    end

    # Builds an fdiv Instruction with the given name. Divides the given lhs by rhs as floats.
    def fdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFDiv(self, lhs, rhs, name))
    end

    # Unsigned remainder.
    def urem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildURem(self, lhs, rhs, name))
    end

    # Signed remainder.
    def srem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSRem(self, lhs, rhs, name))
    end

    # Floating point remainder.
    def frem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFRem(self, lhs, rhs, name))
    end

    # Shift left.
    def shl(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildShl(self, lhs, rhs, name))
    end

    # Logical shift right.
    def lshr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildLShr(self, lhs, rhs, name))
    end

    # Arithmatic shift right.
    def ashr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAShr(self, lhs, rhs, name))
    end

    # Builds an and Instruction with the given name. ANDs lhs and rhs.
    def and(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAnd(self, lhs, rhs, name))
    end

    # Builds a or Instruction with the given name. ORs lhs and rhs.
    def or(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildOr(self, lhs, rhs, name))
    end

    # Builds a xor Instruction with the given name. XORs lhs and rhs.
    def xor(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildXor(self, lhs, rhs, name))
    end

    # Builds a neg Instruction with the given name. Inverts the sign of arg
    # (i.e. multiplication by -1.)
    def neg(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNeg(self, arg, name))
    end

    # Builds a not Instruction with the given name. Boolean negation.
    def not(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNot(self, arg, name))
    end


    # Builds a malloc Instruction with the given name. Mallocs bits for the
    # given type.
    def malloc(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildMalloc(self, LLVM::Type(ty), name))
    end

    # Builds a array malloc Instruction with the given. Mallocs bits for the
    # given array type.
    def array_malloc(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayMalloc(self, LLVM::Type(ty), val, name))
    end

    # Builds a alloc Instruction with the given name. Allocates bits on the
    # stack for the given type.
    def alloca(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildAlloca(self, LLVM::Type(ty), name))
    end

    # Builds a array alloc Instruction with the given. Allocates bits on the
    # stack for the given array type.
    def array_alloca(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayAlloca(self, LLVM::Type(ty), val, name))
    end

    # Builds a free Instruction. Frees the given pointer (an Instruction).
    def free(pointer)
      Instruction.from_ptr(C.LLVMBuildFree(self, pointer))
    end

    # Builds a load Instruction with the given name. Loads the value of the
    # given pointer (an Instruction).
    def load(pointer, name = "")
      Instruction.from_ptr(C.LLVMBuildLoad(self, pointer, name))
    end

    # Builds a store Instruction. Stores the given Value into the given
    # pointer (an Instruction).
    def store(val, pointer)
      Instruction.from_ptr(C.LLVMBuildStore(self, val, pointer))
    end

    # Builds a getelementptr Instruction with the given name. Retrieves the
    # element pointer at the given indices of the pointer (an Instruction).
    # See http://llvm.org/docs/GetElementPtr.html for discussion.
    def gep(pointer, indices, name = "")
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return Instruction.from_ptr(
          C.LLVMBuildGEP(self, pointer, indices_ptr, indices.size, name))
      end
    end

    # Builds a inbounds getelementptr Instruction with the given name.
    # Retrieves the element pointer at the given indices of the pointer (an
    # Instruction). If the indices are outside the allocated pointer the
    # retrieved value is undefined. See http://llvm.org/docs/GetElementPtr.html
    # for discussion.
    def inbounds_gep(pointer, indices, name = "")
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return Instruction.from_ptr(
          C.LLVMBuildInBoundsGEP(self, pointer, indices_ptr, indices.size, name))
      end
    end

    # Builds a struct getelementptr Instruction with the given name.
    # Retrieves the element pointer at the given indices (idx) of the pointer
    # (an Instruction). See http://llvm.org/docs/GetElementPtr.html for
    # discussion.
    def struct_gep(pointer, idx, name = "")
      Instruction.from_ptr(C.LLVMBuildStructGEP(self, pointer, idx, name))
    end

    # Builds a global string Instruction with the given name. Creates a global
    # string.
    def global_string(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalString(self, string, name))
    end

    # Builds a global string Instruction with the given name. Creates a global
    # string pointer.
    def global_string_pointer(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalStringPtr(self, string, name))
    end

    # Builds a trunc Instruction with the given name. Casting.
    def trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildTrunc(self, val, LLVM::Type(ty), name))
    end

    # Builds a zext Instruction with the given name. Casting.
    def zext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExt(self, val, LLVM::Type(ty), name))
    end

    # Builds a sext Instruction with the given name. Casting.
    def sext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExt(self, val, LLVM::Type(ty), name))
    end

    # Builds a fp2ui Instruction with the given name. Casting.
    def fp2ui(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToUI(self, val, LLVM::Type(ty), name))
    end

    # Builds a fp2si Instruction with the given name. Casting.
    def fp2si(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToSI(self, val, LLVM::Type(ty), name))
    end

    # Builds a ui2fp Instruction with the given name. Casting.
    def ui2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildUIToFP(self, val, LLVM::Type(ty), name))
    end

    # Builds a si2fp Instruction with the given name. Casting.
    def si2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSIToFP(self, val, LLVM::Type(ty), name))
    end

    # Builds a fp trunc Instruction with the given name. Casting.
    def fp_trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPTrunc(self, val, LLVM::Type(ty), name))
    end

    # Builds a fp ext Instruction with the given name. Casting.
    def fp_ext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPExt(self, val, LLVM::Type(ty), name))
    end

    # Builds a ptr2int Instruction with the given name. Casting.
    def ptr2int(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrToInt(self, val, LLVM::Type(ty), name))
    end

    # Builds a int2ptr Instruction with the given name. Casting.
    def int2ptr(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildIntToPtr(self, val, LLVM::Type(ty), name))
    end

    # Builds a bit cast Instruction with the given name.
    def bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildBitCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a zext or bit cast Instruction with the given name.
    def zext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExtOrBitCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a sext or bit cast Instruction with the given name.
    def sext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExtOrBitCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a trunc or bit cast Instruction with the given name.
    def trunc_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildTruncOrBitCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a pointer cast Instruction with the given name.
    def pointer_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildPointerCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a int cast Instruction with the given name.
    def int_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildIntCast(self, val, LLVM::Type(ty), name))
    end

    # Builds a fp cast Instruction with the given name.
    def fp_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPCast(self, val, LLVM::Type(ty), name))
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
    def icmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildICmp(self, pred, lhs, rhs, name))
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
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFCmp(self, pred, lhs, rhs, name))
    end

    # Builds a Phi node of the given Type with the given incoming branches.
    def phi(ty, *incoming)
      if incoming.last.kind_of? String
        name = incoming.pop
      else
        name = ""
      end

      phi = Phi.from_ptr(C.LLVMBuildPhi(self, LLVM::Type(ty), name))
      phi.add_incoming(*incoming) unless incoming.empty?
      phi
    end

    # Builds a call Instruction. Calls the given Function with the given
    # args (Instructions).
    def call(fun, *args)
      raise "No fun" if fun.nil?
      if args.last.kind_of? String
        name = args.pop
      else
        name = ""
      end

      args_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size)
      args_ptr.write_array_of_pointer(args)
      CallInst.from_ptr(C.LLVMBuildCall(self, fun, args_ptr, args.size, name))
    end

    # Builds a select Instruction.
    def select(_if, _then, _else, name = "")
      Instruction.from_ptr(C.LLVMBuildSelect(self, _if, _then, _else, name))
    end

    # Builds a va arg Instruction with the given name.
    def va_arg(list, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildVAArg(self, list, LLVM::Type(ty), name))
    end

    # Builds an extract element Instruction. Extracts the element at the given
    # index of vector.
    def extract_element(vector, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractElement(self, vector, index, name))
    end

    # Builds an extract element Instruction with the given name. Inserts the
    # given element at the given index of vector.
    def insert_element(vector, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertElement(self, vector, elem, index, name))
    end

    # Builds a shuffle vector Instruction with the given name.
    def shuffle_vector(vec1, vec2, mask, name = "")
      Instruction.from_ptr(C.LLVMBuildShuffleVector(self, vec1, vec2, mask, name))
    end

    # Builds an extract value arg Instruction with the given name.
    def extract_value(aggregate, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractValue(self, aggregate, index, name))
    end

    # Builds an insert value arg Instruction with the given name.
    def insert_value(aggregate, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertValue(self, aggregate, elem, index, name))
    end

    # Builds an is null Instruction. Checks if val is null.
    def is_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNull(self, val, name))
    end

    # Builds an is not null Instruction. Checks if val is not null.
    def is_not_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNotNull(self, val, name))
    end

    # Builds a ptr diff Instruction with the given name. Retrieves the pointer
    # difference between the given lhs and rhs.
    def ptr_diff(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrDiff(lhs, rhs, name))
    end

    # Disposes the builder.
    def dispose
      C.LLVMDisposeBuilder(@ptr)
    end
  end
end
