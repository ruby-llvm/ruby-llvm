module LLVM
  module Builder
    class Action
      def initialize(&action)
        @action = action
      end
      
      def call(fun, builder)
        @value ||= @action.(fun, builder)
      end
    end
    
    module_function
    
    def action
      Action.new { |f,b| yield f,b }
    end
    
    def const(val)
      action { |_,_| val }
    end
    
    def seq(*actions)
      actions.reduce { |fst, snd|
        action { |f,b|
          fst.(f,b); snd.(f,b)
        }
      }
    end
    
    def recur(*args)
      action { |f,b| call(f, *args).(f,b) }
    end
    
    def current_block
      action { |f,b| C.LLVMGetInsertBlock(b) }
    end
    
    def float(x)
      const(LLVM::Float.from_f(x).to_ptr)
    end
    
    def int32(n)
      const(LLVM::Int32.from_i(n).to_ptr)
    end
    
    def int64(n)
      const(LLVM::Int64.from_i(n).to_ptr)
    end
    
    def basic_block(name = "block")
      action { |f,b|
        block = C.LLVMAppendBasicBlock(f.to_ptr, name)
        prev = C.LLVMGetInsertBlock(b)
        begin
          C.LLVMPositionBuilderAtEnd(b, block) # push
          yield(const(block)).(f, b)
        ensure
          C.LLVMPositionBuilderAtEnd(b, prev) # pop
        end
        block
      }
    end
    
    # Terminators
    
    def ret_void
      action { |f,b| C.LLVMBuildRetVoid(b) }
      nil
    end
    
    def ret(val)
      action { |fun, builder|
        C.LLVMBuildRet(builder, val.(fun, builder))
        nil
      }
    end
    
    def aggregate_ret(*vals)
      action { |fun, builder|
        valsA = vals.map { |v| v.(fun, builder) }
        C.LLVMBuildAggregateRet(builder, valsA, vals.size)
        nil
      }
    end
    
    def br(block)
      action { |fun, builder|
        C.LLVMBuildBr(builder, block.(fun, builder))
        nil
      }
    end
    
    def cond(bool, iftrue, iffalse)
      action { |fun, builder|
        C.LLVMBuildCondBr(builder,
                          bool.(fun, builder),
                          iftrue.(fun, builder),
                          iffalse.(fun, builder))
        nil
      }
    end
    
    def switch(val, default, *cases)
      raise ArgumentError "Odd number list for switch" unless (cases % 2).zero?
      action { |f,b|
        C.LLVMBuildSwitch(b, val.(f,b), default.(f,b), cases.size)
        cases.each_slice(2) do |val, block|
          C.LLVMAddCase(b, val.(f,b), block.(f,b))
        end
        nil
      }
    end
    
    def invoke(fun, args, _then, _catch, name = "invoke")
      action { |f,b|
        C.LLVMBuildInvoke(b, fun.(f,b), args.map { |a| a.(f,b) },
                          _then.(f,b), _catch.(f,b), name)
        nil
      }
    end
    
    def unwind
      action { |f,b|
        C.LLVMBuildUnwind(b)
        nil
      }
    end
    
    def unreachable
      action { |f,b|
        C.LLVMBuildUnreachable(b)
        nil
      }
    end
    
    # Arithmetic
    
    def add(lhs, rhs, name = "add")
      action { |f,b|
        C.LLVMBuildAdd(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def nsw_add(lhs, rhs, name = "nws_add")
      action { |f,b|
        C.LLVMBuildNSWAdd(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def fadd(lhs, rhs, name = "fadd")
      action { |f,b|
        C.LLVMBuildFAdd(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def sub(lhs, rhs, name = "sub")
      action { |f,b|
        C.LLVMBuildSub(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def fsub(lhs, rhs, name = "fsub")
      action { |f,b|
        C.LLVMBuildFSub(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def mul(lhs, rhs, name = "mul")
      action { |f,b|
        C.LLVMBuildMul(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def fmul(lhs, rhs, name = "fmul")
      action { |f,b|
        C.LLVMBuildFMul(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def udiv(lhs, rhs, name = "udiv")
      action { |f,b|
        C.LLVMBuildUDiv(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def sdiv(lhs, rhs, name = "sdiv")
      action { |f,b|
        C.LLVMBuildSDiv(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def exact_sdiv(lhs, rhs, name = "exact_sdiv")
      action { |f,b|
        C.LLVMBuildExactSDiv(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def fdiv(lhs, rhs, name = "fdiv")
      action { |f,b|
        C.LLVMBuildFDiv(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def urem(lhs, rhs, name = "urem")
      action { |f,b|
        C.LLVMBuildURem(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def srem(lhs, rhs, name = "srem")
      action { |f,b|
        C.LLVMBuildSRem(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def frem(lhs, rhs, name = "frem")
      action { |f,b|
        C.LLVMBuildFRem(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def shl(lhs, rhs, name = "shl")
      action { |f,b|
        C.LLVMBuildShl(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def lshr(lhs, rhs, name = "lshr")
      action { |f,b|
        C.LLVMBuildLShr(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def ashr(lhs, rhs, name = "ashr")
      action { |f,b|
        C.LLVMBuildAShr(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def and(lhs, rhs, name = "and")
      action { |f,b|
        C.LLVMBuildAnd(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def or(lhs, rhs, name = "or")
      action { |f,b|
        C.LLVMBuildOr(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def xor(lhs, rhs, name = "xor")
      action { |f,b|
        C.LLVMBuildXor(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def neg(lhs, rhs, name = "neg")
      action { |f,b|
        C.LLVMBuildNeg(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def not(lhs, rhs, name = "not")
      action { |f,b|
        C.LLVMBuildNot(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    # Memory
    
    def malloc(type, name = "malloc #{type}")
      action { |f,b|
        C.LLVMBuildMalloc(b, type, name)
      }
    end
    
    def array_malloc(type, size, name = "malloc #{type}[#{size}]")
      action { |f,b|
        C.LLVMBuildArrayMalloc(b, size.(f,b), name)
      }
    end
    
    def alloca(type, name = "alloca #{type}")
      action { |f,b|
        C.LLVMBuildAlloca(b, type, name)
      }
    end
    
    def array_alloca(type, size, name = "alloca #{type}[#{size}]")
      action { |f,b|
        C.LLVMBuildArrayAlloca(b, type, size.(f,b), name)
      }
    end
    
    def free(pointer)
      action { |f,b|
        C.LLVMBuildFree(b, pointer.(f,b))
      }
    end
    
    def load(pointer, name = "load")
      action { |f,b|
        C.LLVMBuildLoad(b, pointer.(f,b), name)
      }
    end
    
    def store(val, pointer)
      action { |f,b|
        C.LLVMBuildStore(b, val.(f,b), pointer.(f,b))
      }
    end
    
    def gep(pointer, *indices)
      indices, name = String === indices[-1] ?
        [indices[0..-2], indices[-1]] :
        [indices, "gep"]
      
      action { |f,b|
        gep = nil
        FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * indices.size) do |indices_ptr|
          indices_ptr.write_array_of_pointer indices.map { |i| i.(f,b) }
          gep = C.LLVMBuildGEP(b,
            pointer.(f,b),
            indices_ptr,
            indices.size,
            name)
        end
        gep
      }
    end
    
    def in_bounds_gep(pointer, indices, name = "inbounds gep")
      action { |f,b|
        C.LLVMBuildInBoundsGEP(b,
          pointer.(f,b), 
          indices.map { |i| i.(f,b) },
          indices.size,
          name)
      }
    end
    
    def global_string(string, name = "global string")
      action { |f,b|
        C.LLVMBuildGlobalString(b, string, name)
      }
    end
    
    def global_string_pointer(string, name = "global string pointer")
      action { |f,b|
        C.LLVMBuildGlobalStringPointer(b, string, name)
      }
    end
    
    # Casts
    
    def trunc(val, type, name = "trunc")
      action { |f,b|
        C.LLVMBuildTrunc(b, val.(f,b), type, name)
      }
    end
    
    def zext(val, type, name = "zext")
      action { |f,b|
        C.LLVMBuildZExt(b, val.(f,b), type, name)
      }
    end
    
    def sext(val, type, name = "sext")
      action { |f,b|
        C.LLVMBuildSExt(b, val.(f,b), type, name)
      }
    end
    
    def fp2ui(val, type, name = "fp to ui")
      action { |f,b|
        C.LLVMBuildFPToUI(b, val.(f,b), type, name)
      }
    end
    
    def fp2si(val, type, name = "fp to si")
      action { |f,b|
        C.LLVMBuildFPToSI(b, val.(f,b), type, name)
      }
    end
    
    def ui2fp(val, type, name = "ui to fp")
      action { |f,b|
        C.LLVMBuildUIToFP(b, val.(f,b), type, name)
      }
    end
    
    def si2fp(val, type, name = "si to fp")
      action { |f,b|
        C.LLVMBuildSIToFP(b, val.(f,b), type, name)
      }
    end
    
    def fp_trunc(val, type, name = "fp trunc")
      action { |f,b|
        C.LLVMBuildFPTrunc(b, val.(f,b), type, name)
      }
    end
    
    def fp_ext(val, type, name = "fp ext")
      action { |f,b|
        C.LLVMBuildFPExt(b, val.(f,b), type, name)
      }
    end
    
    def ptr2int(val, type, name = "ptr to int")
      action { |f,b|
        C.LLVMBuildPtrToInt(b, val.(f,b), type, name)
      }
    end
    
    def int2ptr(val, type, name = "int to ptr")
      action { |f,b|
        C.LLVMBuildIntToPtr(b, val.(f,b), type, name)
      }
    end
    
    def bit_cast(val, type, name = "bit cast")
      action { |f,b|
        C.LLVMBuildBitCast(b, val.(f,b), type, name)
      }
    end
    
    def zext_or_bit_cast(val, type, name = "zext or bit cast")
      action { |f,b|
        C.LLVMBuildZExtOrBitCast(b, val.(f,b), type, name)
      }
    end
    
    def sext_or_bit_cast(val, type, name = "sext or bit cast")
      action { |f,b|
        C.LLVMBuildSExtOrBitCast(b, val.(f,b), type, name)
      }
    end
    
    def trunc_or_bit_cast(val, type, name = "trunc or bit cast")
      action { |f,b|
        C.LLVMBuildTruncOrBitCast(b, val.(f,b), type, name)
      }
    end
    
    def pointer_cast(val, type, name = "pointer cast")
      action { |f,b|
        C.LLVMBuildPointerCast(b, val.(f,b), type, name)
      }
    end
    
    def int_cast(val, type, name = "int cast")
      action { |f,b|
        C.LLVMBuildIntCast(b, val.(f,b), type, name)
      }
    end
    
    def fp_cast(val, type, name = "fp cast")
      action { |f,b|
        C.LLVMBuildFPCast(b, val.(f,b), type, name)
      }
    end
    
    # Comparisons
    
    def icmp(pred, lhs, rhs, name = "icmp")
      action { |f,b|
        C.LLVMBuildICmp(b, Predicates.sym2ipred(pred),
                        lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    def fcmp(pred, lhs, rhs, name = "fcmp")
      action { |f,b|
        C.LLVMBuildFCmp(b, Predicates.sym2rpred(pred),
                        lhs.(f,b), rhs.(f,b), name)
      }
    end
    
    # Misc
    
    def phi(type, name, *incoming)
      action { |f,b|
        phi = C.LLVMBuildPhi(self, type, name.(f,b))
        unless incoming.empty?
          vals, blocks = [], []
          incoming.each_with_index do |node, i|
            (i % 2 == 0 ? vals : blocks) << node
          end
          
          size = vals.size
          FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * size) do |vals_ptr|
            vals_ptr.write_array_of_pointer vals.map { |val|
              val.(f,b)
            }
            FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * size) do |blocks_ptr|
              blocks_ptr.write_array_of_pointer blocks.map { |block|
                block.(f,b)
              }
              C.LLVMAddIncoming(self, vals_ptr, blocks_ptr, vals.size)
            end
          end
        end
        phi
      }
    end
    
    def call(fun, args, name = "call #{fun}")
      action { |f,b|
        args_ptr = FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * args.size)
        args_ptr.write_array_of_pointer args.map { |a| a.(f,b) }
        C.LLVMBuildCall(b, fun, args_ptr, args.size, name)
      }
    end

    def select(test, iftrue, iffalse, name = "select")
      action { |f,b|
        C.LLVMBuildSelect(b, iftrue.(f,b), iffalse.(f,b), name)
      }
    end
    
    def va_arg(list, type, name = "va_arg")
      action { |f,b|
        C.LLVMBuildVAArg(b, list.(f,b), type, name)
      }
    end
    
    def extract_element(vector, index, name = "extract element")
      action { |f,b|
        C.LLVMBuidExtractElement(b, vector.(f,b), index.(f,b), name)
      }
    end
    
    def shuffle_vector(vec1, vec2, mask, name = "shuffle vector")
      action { |f,b|
        C.LLVMBuildShuffleVector(b, vec1.(f,b), vec2.(f,b), name)
      }
    end
    
    def extract_value(aggregate, index, name = "extract value")
      action { |f,b|
        C.LLVMBuildExtractValue(b, aggregate.(f,b), index.(f,b), name)
      }
    end
    
    def insert_value(aggregate, elem, index, name = "")
      action { |f,b|
        C.LLVMBuildInsertValue(b, aggregate.(f,b), elem.(f,b), index.(f,b), name)
      }
    end
    
    def is_null(val, name = "is null")
      action { |f,b|
        C.LLVMBuildIsNull(b, val.(f,b), name)
      }
    end
    
    def is_not_null(val, name = "is not null")
      action { |f,b|
        C.LLVMBuildIsNotNull(b, val.(f,b), name)
      }
    end
    
    def ptr_diff(lhs, rhs, name = "ptr diff")
      action { |f,b|
        C.LLVMBuildPtrDiff(b, lhs.(f,b), rhs.(f,b), name)
      }
    end
  end
end
