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
    
    def position_at_end(block)
      C.LLVMPositionBuilderAtEnd(self, block)
      self
    end
    
    def get_insert_block
      BasicBlock.from_ptr(C.LLVMGetInsertBlock(self))
    end
    
    # Terminators
    
    def ret_void
      Instruction.from_ptr(C.LLVMBuildRetVoid(self))
    end
    
    def ret(val)
      Instruction.from_ptr(C.LLVMBuildRet(self, val))
    end
    
    def aggregate_ret(*vals)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * vals.size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        Instruction.from_ptr(C.LLVMBuildAggregateRet(self, vals_ptr, vals.size))
      end
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
    
    def neg(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNeg(self, arg, name))
    end
    
    def not(arg, name = "")
      Instruction.from_ptr(C.LLVMBuildNot(self, arg, name))
    end
    
    # Memory
    
    def malloc(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildMalloc(self, LLVM::Type(ty), name))
    end
    
    def array_malloc(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayMalloc(self, LLVM::Type(ty), val, name))
    end
    
    def alloca(ty, name = "")
      Instruction.from_ptr(C.LLVMBuildAlloca(self, LLVM::Type(ty), name))
    end
    
    def array_alloca(ty, val, name = "")
      Instruction.from_ptr(C.LLVMBuildArrayAlloca(self, LLVM::Type(ty), val, name))
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
    
    def gep(pointer, indices, name = "")
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return Instruction.from_ptr(
          C.LLVMBuildInBoundsGEP(self, pointer, indices_ptr, indices.size, name))
      end
    end
    
    def inbounds_gep(pointer, indices, name = "")
      indices = Array(indices)
      FFI::MemoryPointer.new(FFI.type_size(:pointer) * indices.size) do |indices_ptr|
        indices_ptr.write_array_of_pointer(indices)
        return Instruction.from_ptr(
          C.LLVMBuildGEP(self, pointer, indices_ptr, indices.size, name))
      end
    end
    
    def struct_gep(pointer, idx, name = "")
      Instruction.from_ptr(C.LLVMBuildStructGEP(self, pointer, idx, name))
    end
    
    def global_string(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalString(self, string, name))
    end
    
    def global_string_pointer(string, name = "")
      Instruction.from_ptr(C.LLVMBuildGlobalStringPointer(self, string, name))
    end
    
    # Casts
    
    def trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildTrunc(self, val, LLVM::Type(ty), name))
    end
    
    def zext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExt(self, val, LLVM::Type(ty), name))
    end
    
    def sext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExt(self, val, LLVM::Type(ty), name))
    end
    
    def fp2ui(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToUI(self, val, LLVM::Type(ty), name))
    end
    
    def fp2si(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPToSI(self, val, LLVM::Type(ty), name))
    end
    
    def ui2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildUIToFP(self, val, LLVM::Type(ty), name))
    end
    
    def si2fp(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSIToFP(self, val, LLVM::Type(ty), name))
    end
    
    def fp_trunc(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPTrunc(self, val, LLVM::Type(ty), name))
    end
    
    def fp_ext(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPExt(self, val, LLVM::Type(ty), name))
    end
    
    def ptr2int(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildPtrToInt(self, val, LLVM::Type(ty), name))
    end
    
    def int2ptr(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildIntToPtr(self, val, LLVM::Type(ty), name))
    end
    
    def bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildBitCast(self, val, LLVM::Type(ty), name))
    end
    
    def zext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildZExtOrBitCast(self, val, LLVM::Type(ty), name))
    end
    
    def sext_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildSExtOrBitCast(self, val, LLVM::Type(ty), name))
    end
    
    def trunc_or_bit_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildTruncOrBitCast(self, val, LLVM::Type(ty), name))
    end
    
    def pointer_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildPointerCast(self, val, LLVM::Type(ty), name))
    end
    
    def int_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildIntCast(self, val, LLVM::Type(ty), name))
    end
    
    def fp_cast(val, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildFPCast(self, val, LLVM::Type(ty), name))
    end
    
    # Comparisons
    
    def icmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildICmp(self, pred, lhs, rhs, name))
    end
    
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFCmp(self, pred, lhs, rhs, name))
    end
    
    # Misc
    
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
    
    def call(fun, *args)
      if args.last.kind_of? String
        name = args.pop
      else
        name = ""
      end

      args_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size)
      args_ptr.write_array_of_pointer(args)
      CallInst.from_ptr(C.LLVMBuildCall(self, fun, args_ptr, args.size, name))
    end
    
    def select(_if, _then, _else, name = "")
      Instruction.from_ptr(C.LLVMBuildSelect(self, _if, _then, _else, name))
    end
    
    def va_arg(list, ty, name = "")
      Instruction.from_ptr(C.LLVMBuildVAArg(self, list, LLVM::Type(ty), name))
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
