module LLVM
  class Builder
    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end

    # @private
    def to_ptr
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


    # @LLVMinst ret
    def ret_void
      Instruction.from_ptr(C.LLVMBuildRetVoid(self))
    end

    # @LLVMinst ret
    def ret(val)
      Instruction.from_ptr(C.LLVMBuildRet(self, val))
    end

    # Builds a ret instruction returning multiple values.
    # @LLVMinst ret
    def aggregate_ret(*vals)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * vals.size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        Instruction.from_ptr(C.LLVMBuildAggregateRet(self, vals_ptr, vals.size))
      end
    end

    # Unconditional branching (i.e. goto)
    # @LLVMinst br
    def br(block)
      Instruction.from_ptr(
        C.LLVMBuildBr(self, block))
    end

    # Conditional branching (i.e. if)
    # @LLVMinst br
    def cond(cond, iftrue, iffalse)
      Instruction.from_ptr(
        C.LLVMBuildCondBr(self, cond, iftrue, iffalse))
    end

    # @LLVMinst switch
    def switch(val, default, ncases)
      SwitchInst.from_ptr(C.LLVMBuildSwitch(self, val, default, ncases))
    end

    # Invoke a function which may potentially unwind
    # @LLVMinst invoke
    def invoke(fun, args, _then, _catch, name = "")
      Instruction.from_ptr(
        C.LLVMBuildInvoke(self,
          fun, args, args.size, _then, _catch, name))
    end

    # Builds an unwind Instruction.
    # @LLVMinst unwind
    def unwind
      Instruction.from_ptr(C.LLVMBuildUnwind(self))
    end

    # @LLVMinst unreachable
    def unreachable
      Instruction.from_ptr(C.LLVMBuildUnreachable(self))
    end

    # @LLVMinst add
    def add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAdd(self, lhs, rhs, name))
    end

    # No signed wrap addition.
    # @LLVMinst add
    def nsw_add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildNSWAdd(self, lhs, rhs, name))
    end

    # @LLVMinst fadd
    def fadd(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFAdd(self, lhs, rhs, name))
    end

    # @LLVMinst sub
    def sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSub(self, lhs, rhs, name))
    end

    # @LLVMinst fsub
    def fsub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFSub(self, lhs, rhs, name))
    end

    # @LLVMinst mul
    def mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildMul(self, lhs, rhs, name))
    end

    # @LLVMinst fmul
    def fmul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFMul(self, lhs, rhs, name))
    end

    # Unsigned integer division
    # @LLVMinst udiv
    def udiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildUDiv(self, lhs, rhs, name))
    end

    # Signed division
    # @LLVMinst sdiv
    def sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSDiv(self, lhs, rhs, name))
    end

    # Signed exact division
    # @LLVMinst sdiv
    def exact_sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildExactSDiv(self, lhs, rhs, name))
    end

    # @LLVMinst fdiv
    def fdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFDiv(self, lhs, rhs, name))
    end

    # @LLVMinst urem
    def urem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildURem(self, lhs, rhs, name))
    end

    # @LLVMinst srem
    def srem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSRem(self, lhs, rhs, name))
    end

    # @LLVMinst frem
    def frem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFRem(self, lhs, rhs, name))
    end

    # @LLVMinst shl
    def shl(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildShl(self, lhs, rhs, name))
    end

    # Shifts right with zero fill.
    # @LLVMinst lshr
    def lshr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildLShr(self, lhs, rhs, name))
    end

    # Arithmatic shift right.
    # @LLVMinst ashr
    def ashr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAShr(self, lhs, rhs, name))
    end

    # @LLVMinst and
    def and(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAnd(self, lhs, rhs, name))
    end

    # @LLVMinst or
    def or(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildOr(self, lhs, rhs, name))
    end

    # @LLVMinst xor
    def xor(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildXor(self, lhs, rhs, name))
    end

    # Integer negation (i.e. multiplication by -1).
    def neg(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNeg(self, arg, name))
    end

    # Boolean negation.
    def not(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNot(self, arg, name))
    end

    # Builds a malloc Instruction for the given type.
    def malloc(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildMalloc(self, LLVM::Type(ty), name))
    end

    # Builds a malloc Instruction for the given array type.
    def array_malloc(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayMalloc(self, LLVM::Type(ty), val, name))
    end

    # Stack allocation.
    # @LLVMinst alloca
    def alloca(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildAlloca(self, LLVM::Type(ty), name))
    end

    # Array stack allocation
    # @param LLVM::Value used to initialize each element.
    # @LLVMinst alloca
    def array_alloca(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayAlloca(self, LLVM::Type(ty), val, name))
    end

    # Builds a free Instruction. Frees the given pointer (an Instruction).
    def free(pointer)
      Instruction.from_ptr(C.LLVMBuildFree(self, pointer))
    end

    # Builds a load Instruction with the given name. Loads the value of the
    # given pointer (an Instruction).
    # @LLVMinst load
    def load(pointer, name = "")
      Instruction.from_ptr(C.LLVMBuildLoad(self, pointer, name))
    end

    # Builds a store Instruction. Stores the given Value into the given
    # pointer (an Instruction).
    # @LLVMinst store
    def store(val, pointer)
      Instruction.from_ptr(C.LLVMBuildStore(self, val, pointer))
    end

    # Builds a getelementptr Instruction with the given name. Retrieves the
    # element pointer at the given indices of the pointer (an Instruction).
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
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
    # retrieved value is undefined.
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
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
    # @LLVMinst gep
    # @see http://llvm.org/docs/GetElementPtr.html
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

    # @LLVMinst trunc
    def trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildTrunc(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst zext
    def zext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExt(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst sext
    def sext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExt(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst fptoui
    def fp2ui(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToUI(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst fptosi
    def fp2si(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToSI(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst uitofp
    def ui2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildUIToFP(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst sitofp
    def si2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSIToFP(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst fptrunc
    def fp_trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPTrunc(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst fpext
    def fp_ext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPExt(self, val, LLVM::Type(ty), name))
    end

    # Cast a pointer to an int. Useful for pointer arithmetic.
    # @LLVMinst ptrtoint
    def ptr2int(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrToInt(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst inttoptr
    def int2ptr(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildIntToPtr(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst bitcast
    def bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildBitCast(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst zext
    # @LLVMinst bitcast
    def zext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExtOrBitCast(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst sext
    # @LLVMinst bitcast
    def sext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExtOrBitCast(self, val, LLVM::Type(ty), name))
    end

    # @LLVMinst trunc
    # @LLVMinst bitcast
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
    # @LLVMinst icmp
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
    # @LLVMinst fcmp
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFCmp(self, pred, lhs, rhs, name))
    end

    # Builds a Phi node of the given Type with the given incoming branches.
    # @LLVMinst phi
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
    # @LLVMinst call
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

    # @LLVMinst select
    def select(_if, _then, _else, name = "")
      Instruction.from_ptr(C.LLVMBuildSelect(self, _if, _then, _else, name))
    end

    # @LLVMinst va_arg
    def va_arg(list, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildVAArg(self, list, LLVM::Type(ty), name))
    end

    # @LLVMinst extractelement
    def extract_element(vector, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractElement(self, vector, index, name))
    end

    # @LLVMinst insertelement
    def insert_element(vector, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertElement(self, vector, elem, index, name))
    end

    # @LLVMinst shufflevector
    def shuffle_vector(vec1, vec2, mask, name = "")
      Instruction.from_ptr(C.LLVMBuildShuffleVector(self, vec1, vec2, mask, name))
    end

    # LLVMinst extractvalue
    def extract_value(aggregate, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractValue(self, aggregate, index, name))
    end

    # @LLVMinst insertvalue
    def insert_value(aggregate, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertValue(self, aggregate, elem, index, name))
    end

    # Check if a value is null.
    def is_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNull(self, val, name))
    end

    # Check if a value is not null.
    def is_not_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNotNull(self, val, name))
    end

    # Retrieves the pointer difference between the given lhs and rhs.
    def ptr_diff(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrDiff(lhs, rhs, name))
    end

    # Disposes the builder.
    def dispose
      C.LLVMDisposeBuilder(@ptr)
    end
  end
end
