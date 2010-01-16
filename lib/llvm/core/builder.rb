module LLVM
  class Builder
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.create
      new(C.LLVMCreateBuilder())
    end
    
    def self.create_in_context(context)
      new(C.LLVMCreateBuilderInContext(context))
    end
    
    def position_at_end(block)
      C.LLVMPositionBuilderAtEnd(self, block)
      nil
    end
    
    def get_insert_block
      BasicBlock.from_ptr(C.LLVMGetInsertBlock(self))
    end
    
    def with_block(block)
      prev = get_insert_block
      position_at_end(block)
      yield
    ensure
      position_at_end(prev)
    end
    
    # Terminators
    
    def ret_void
      Instruction.from_ptr(C.LLVMBuildRetVoid(self))
    end
    
    def ret(val)
      Instruction.from_ptr(C.LLVMBuildRet(self, val))
    end
    
    def aggregate_ret(*vals)
      Instruction.from_ptr(C.LLVMBuildAggregateRet(self, vals, vals.size))
    end
    
    def br(block)
      Instruction.from_ptr(
        C.LLVMBuildBr(self, block))
    end
    
    def cond(cond, iftrue, iffalse)
      Instruction.from_ptr(
        C.LLVMBuildCondBr(self, cond, iftrue, iffalse))
    end
    
    def switch(val, block, ncases)
      SwitchInst.from_ptr(C.LLVMBuildSwitch(self, val, block, ncases))
    end
    
    def invoke(fun, args, _then, _catch, name = "")
      Instruction.from_ptr(
        C.LLVMBuildInvoke(self,
          fun, args, args.size, _then, _catch, name))
    end
    
    def unwind
      Instruction.from_ptr(C.LLVMBuildUnwind(self))
    end
    
    def unreachable
      Instruction.from_ptr(C.LLVMBuildUnreachable(self))
    end
    
    # Arithmetic
    
    def add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAdd(self, lhs, rhs, name))
    end
    
    def nsw_add(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildNSWAdd(self, lhs, rhs, name))
    end
    
    def fadd(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFAdd(self, lhs, rhs, name))
    end
    
    def sub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSub(self, lhs, rhs, name))
    end
    
    def fsub(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFSub(self, lhs, rhs, name))
    end
    
    def mul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildMul(self, lhs, rhs, name))
    end
    
    def fmul(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFMul(self, lhs, rhs, name))
    end
    
    def udiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildUDiv(self, lhs, rhs, name))
    end
    
    def sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSDiv(self, lhs, rhs, name))
    end
    
    def exact_sdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildExactSDiv(self, lhs, rhs, name))
    end
    
    def fdiv(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFDiv(self, lhs, rhs, name))
    end
    
    def urem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildURem(self, lhs, rhs, name))
    end
    
    def srem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildSRem(self, lhs, rhs, name))
    end
    
    def frem(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFRem(self, lhs, rhs, name))
    end
    
    def shl(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildShl(self, lhs, rhs, name))
    end
    
    def lshr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildLShr(self, lhs, rhs, name))
    end
    
    def ashr(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAShr(self, lhs, rhs, name))
    end
    
    def and(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildAnd(self, lhs, rhs, name))
    end
    
    def or(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildOr(self, lhs, rhs, name))
    end
    
    def xor(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildXor(self, lhs, rhs, name))
    end
    
    def neg(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildNeg(self, lhs, rhs, name))
    end
    
    def not(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildNot(self, lhs, rhs, name))
    end
    
    # Memory
    
    def malloc(type, name = "")
      Instruction.from_ptr(C.LLVMBuildMalloc(self, type, name))
    end
    
    def array_malloc(type, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayMalloc(self, type, val, name))
    end
    
    def alloca(type, name = "")
      Instruction.from_ptr(C.LLVMBuildAlloca(self, type, name))
    end
    
    def array_alloca(type, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayAlloca(self, type, val, name))
    end
    
    def free(pointer)
      Instruction.from_ptr(C.LLVMBuildFree(self, pointer))
    end
    
    def load(pointer, name = "")
      Instruction.from_ptr(C.LLVMBuildLoad(self, pointer, name))
    end
    
    def store(val, pointer)
      Instruction.from_ptr(C.LLVMBuildStore(self, val, pointer))
    end
    
    def gep(pointer, indices, inbounds = false, name = "")
      Instruction.from_ptr(inbounds ?
        C.LLVMBuildInBoundsGEP(self, pointer, indices, indices.size, name) :
        C.LLVMBuildGEP(self, pointer, indices, indices.size, name))
    end
    
    def global_string(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalString(self, string, name))
    end
    
    def global_string_pointer(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalStringPointer(self, string, name))
    end
    
    # Casts
    
    def trunc(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildTrunc(self, val, type, name))
    end
    
    def zext(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildZExt(self, val, type, name))
    end
    
    def sext(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildSExt(self, val, type, name))
    end
    
    def fp2ui(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToUI(self, val, type, name))
    end
    
    def fp2si(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToSI(self, val, type, name))
    end
    
    def ui2fp(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildUIToFP(self, val, type, name))
    end
    
    def si2fp(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildSIToFP(self, val, type, name))
    end
    
    def fp_trunc(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildFPTrunc(self, val, type, name))
    end
    
    def fp_ext(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildFPExt(self, val, type, name))
    end
    
    def ptr2int(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrToInt(self, val, type, name))
    end
    
    def int2ptr(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildIntToPtr(self, val, type, name))
    end
    
    def bit_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildBitCast(self, val, type, name))
    end
    
    def zext_or_bit_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildZExtOrBitCast(self, val, type, name))
    end
    
    def sext_or_bit_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildSExtOrBitCast(self, val, type, name))
    end
    
    def trunc_or_bit_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildTruncOrBitCast(self, val, type, name))
    end
    
    def pointer_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildPointerCast(self, val, type, name))
    end
    
    def int_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildIntCast(self, val, type, name))
    end
    
    def fp_cast(val, type, name = "")
      Instruction.from_ptr(C.LLVMBuildFPCast(self, val, type, name))
    end
    
    # Comparisons
    
    def icmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildICmp(self, pred, lhs, rhs, name))
    end
    
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFCmp(self, pred, lhs, rhs, name))
    end
    
    # Misc
    
    def phi(type, *incoming)
      incoming, name = case incoming[-1]
        when String then [incoming[0..-2], incoming[-1]]
        else [incoming, ""]
      end
      phi = Phi.from_ptr(C.LLVMBuildPhi(self, type, name))
      phi.add_incoming(*incoming) unless incoming.empty?
      phi
    end
    
    def call(fun, *args)
      args, name = case args[-1]
        when String then [args[0..-2], args[-1]]
        else [args, ""]
      end
      args_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size)
      args_ptr.write_array_of_pointer(args)
      CallInst.from_ptr(C.LLVMBuildCall(self, fun, args_ptr, args.size, name))
    end
    
    def select(_if, _then, _else, name = "")
      Instruction.from_ptr(C.LLVMBuildSelect(self, _if, _then, _else, name))
    end
    
    def va_arg(list, type, name = "")
      Instruction.from_ptr(C.LLVMBuildVAArg(self, list, type, name))
    end
    
    def extract_element(vector, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractElement(self, vector, index, name))
    end
    
    def insert_element(vector, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertElement(self, vector, elem, index, name))
    end
    
    def shuffle_vector(vec1, vec2, mask, name = "")
      Instruction.from_ptr(C.LLVMBuildShuffleVector(self, vec1, vec2, mask, name))
    end
    
    def extract_value(aggregate, index, name = "")
      Instruction.from_ptr(C.LLVMBuildExtractValue(self, aggregate, index, name))
    end
    
    def insert_value(aggregate, elem, index, name = "")
      Instruction.from_ptr(C.LLVMBuildInsertValue(self, aggregate, elem, index, name))
    end
    
    def is_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNull(self, val, name))
    end
    
    def is_not_null(val, name = "")
      Instruction.from_ptr(C.LLVMBuildIsNotNull(self, val, name))
    end
    
    def ptr_diff(lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrDiff(lhs, rhs, name))
    end
    
    def dispose
      C.LLVMDisposeBuilder(@ptr)
    end
  end
end
