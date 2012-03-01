require 'llvm'

module LLVM
  # @private
  module C
    enum :attribute, [
      :ext,               1 <<  0,
      :sext,              1 <<  1,
      :no_return,         1 <<  2,
      :in_reg,            1 <<  3,
      :struct_ret,        1 <<  4,
      :no_unwind,         1 <<  5,
      :no_alias,          1 <<  6,
      :by_val,            1 <<  7,
      :nest,              1 <<  8,
      :read_none,         1 <<  9,
      :read_only,         1 << 10,
      :no_inline,         1 << 11,
      :always_inline,     1 << 12,
      :optimize_for_size, 1 << 13,
      :stack_protect,     1 << 14,
      :stack_protect_req, 1 << 15,
      :alignment,        31 << 16,
      :no_capture,        1 << 21,
      :no_red_zone,       1 << 22,
      :no_implicit_float, 1 << 23,
      :naked,             1 << 24,
      :inline_hint,       1 << 25,
      :stack_alignment,   7 << 26,
      :returns_twice,     1 << 29,
      :uw_table,          1 << 30,
      :non_lazy_bind,     1 << 31
    ]

    enum :opcode, [
      # Terminator Instructions
      :ret,             1,
      :br,              2,
      :switch,          3,
      :indirectbr,      4,
      :invoke,          5,
      # removed 6 due to API changes
      :unreachable,     7,

      # Standard Binary Operators
      :add,             8,
      :fadd,            9,
      :sub,             10,
      :fsub,            11,
      :mul,             12,
      :fmul,            13,
      :udiv,            14,
      :sdiv,            15,
      :fdiv,            16,
      :urem,            17,
      :srem,            18,
      :frem,            19,

      # Logical Operators
      :shl,             20,
      :lshr,            21,
      :ashr,            22,
      :and,             23,
      :or,              24,
      :xor,             25,

      # Memory Operators
      :alloca,          26,
      :load,            27,
      :store,           28,
      :getelementptr,   29,

      # Cast Operators
      :trunc,           30,
      :zext,            31,
      :sext,            32,
      :fptoui,          33,
      :fptosi,          34,
      :uitofp,          35,
      :sitofp,          36,
      :fptrunc,         37,
      :fpext,           38,
      :ptrtoint,        39,
      :inttoptr,        40,
      :bitcast,         41,

      # Other Operators
      :icmp,            42,
      :fcmp,            43,
      :phi,             44,
      :call,            45,
      :select,          46,
      :user_op_1,       47,
      :user_op_2,       48,
      :vaarg,           49,
      :extractelement,  50,
      :insertelement,   51,
      :shufflevector,   52,
      :extractvalue,    53,
      :insertvalue,     54,
      
      # Atomic Operators
      :fence,           55,
      :atomic_cmp_xchg, 56,
      :atomic_rmw,      57,
      
      # Exception Handling Operators
      :resume,          58,
      :landing_pad,     59,
      :unwind,          60
    ]

    enum :type_kind, [
      :void,
      :float,
      :double,
      :x86_fp80,
      :fp128,
      :ppc_fp128,
      :label,
      :integer,
      :function,
      :struct,
      :array,
      :pointer,
      :vector,
      :metadata,
      :x86_mmx
    ]
    
    enum :linkage, [
      :external,
      :available_externally,
      :link_once_any,
      :link_once_odr,
      :weak_any,
      :weak_odr,
      :appending,
      :internal,
      :private,
      :dll_import,
      :dll_export,
      :external_weak,
      :ghost,
      :common,
      :linker_private
    ]
    
    enum :visibility, [
      :default,
      :hidden,
      :protected
    ]
    
    enum :call_conv, [
      :ccall,         0,
      :fastcall,      8,
      :coldcall,      9,
      :x86_stdcall,  64,
      :x86_fastcall, 65
    ]
    
    enum :int_predicate, [
      :eq,  32,
      :ne,  33,
      :ugt, 34,
      :uge, 35,
      :ult, 36,
      :ule, 37,
      :sgt, 38,
      :sge, 39,
      :slt, 40,
      :sle, 41
    ]
    
    enum :real_predicate, [
      :false,
      :oeq,
      :ogt,
      :oge,
      :olt,
      :ole,
      :one,
      :ord,
      :uno,
      :ueq,
      :ugt,
      :uge,
      :ult,
      :ule,
      :une,
      :true
    ]
    
    enum :landing_pad_clause_type, [
      :catch,
      :filter
    ]
    
    # Error handling
    attach_function :dispose_message, :LLVMDisposeMessage, [:pointer], :void
    
    # Contexts
    attach_function :context_create, :LLVMContextCreate, [], :pointer
    attach_function :get_global_context, :LLVMGetGlobalContext, [], :pointer
    attach_function :context_dispose, :LLVMContextDispose, [:pointer], :void
    
    # Modules
    attach_function :module_create_with_name, :LLVMModuleCreateWithName, [:string], :pointer
    attach_function :module_create_with_name_in_context, :LLVMModuleCreateWithNameInContext, [:string, :pointer], :pointer
    attach_function :dispose_module, :LLVMDisposeModule, [:pointer], :void
    attach_function :get_data_layout, :LLVMGetDataLayout, [:pointer], :string
    attach_function :set_data_layout, :LLVMSetDataLayout, [:pointer, :string], :void
    attach_function :get_target, :LLVMGetTarget, [:pointer], :string
    attach_function :set_target, :LLVMSetTarget, [:pointer, :string], :void
    attach_function :get_type_by_name, :LLVMGetTypeByName, [:pointer, :string], :pointer
    attach_function :dump_module, :LLVMDumpModule, [:pointer], :void
    
    # Types
    attach_function :get_type_kind, :LLVMGetTypeKind, [:pointer], :type_kind
    attach_function :type_is_sized, :LLVMTypeIsSized, [:pointer], :int
    attach_function :get_type_context, :LLVMGetTypeContext, [:pointer], :pointer
    
    # Integer types
    attach_function :int1_type_in_context, :LLVMInt1TypeInContext, [:pointer], :pointer
    attach_function :int8_type_in_context, :LLVMInt8TypeInContext, [:pointer], :pointer
    attach_function :int16_type_in_context, :LLVMInt16TypeInContext, [:pointer], :pointer
    attach_function :int32_type_in_context, :LLVMInt32TypeInContext, [:pointer], :pointer
    attach_function :int64_type_in_context, :LLVMInt64TypeInContext, [:pointer], :pointer
    attach_function :int_type_in_context, :LLVMIntTypeInContext, [:pointer, :uint], :pointer
    
    attach_function :int1_type, :LLVMInt1Type, [], :pointer
    attach_function :int8_type, :LLVMInt8Type, [], :pointer
    attach_function :int16_type, :LLVMInt16Type, [], :pointer
    attach_function :int32_type, :LLVMInt32Type, [], :pointer
    attach_function :int64_type, :LLVMInt64Type, [], :pointer
    attach_function :int_type, :LLVMIntType, [:uint], :pointer
    attach_function :get_int_type_width, :LLVMGetIntTypeWidth, [:pointer], :uint
    
    # Real types
    attach_function :float_type_in_context, :LLVMFloatTypeInContext, [:pointer], :pointer
    attach_function :double_type_in_context, :LLVMDoubleTypeInContext, [:pointer], :pointer
    attach_function :x86fp80_type_in_context, :LLVMX86FP80TypeInContext, [:pointer], :pointer
    attach_function :fp128_type_in_context, :LLVMFP128TypeInContext, [:pointer], :pointer
    attach_function :ppcfp128_type_in_context, :LLVMPPCFP128TypeInContext, [:pointer], :pointer
    
    attach_function :float_type, :LLVMFloatType, [], :pointer
    attach_function :double_type, :LLVMDoubleType, [], :pointer
    attach_function :x86fp80_type, :LLVMX86FP80Type, [], :pointer
    attach_function :fp128_type, :LLVMFP128Type, [], :pointer
    attach_function :ppcfp128_type, :LLVMPPCFP128Type, [], :pointer
    
    # Function types
    attach_function :function_type, :LLVMFunctionType, [:pointer, :pointer, :uint, :int], :pointer
    attach_function :is_function_var_arg, :LLVMIsFunctionVarArg, [:pointer], :int
    attach_function :get_return_type, :LLVMGetReturnType, [:pointer], :pointer
    attach_function :count_param_types, :LLVMCountParamTypes, [:pointer], :uint
    attach_function :get_param_types, :LLVMGetParamTypes, [:pointer, :pointer], :void
    
    # Struct types
    attach_function :struct_type_in_context, :LLVMStructTypeInContext, [:pointer, :pointer, :uint, :int], :pointer
    attach_function :struct_type, :LLVMStructType, [:pointer, :uint, :int], :pointer
    attach_function :struct_create_named, :LLVMStructCreateNamed, [:pointer, :string], :pointer
    attach_function :get_struct_name, :LLVMGetStructName, [:pointer], :string
    attach_function :struct_set_body, :LLVMStructSetBody, [:pointer, :pointer, :uint, :int], :void
    attach_function :count_struct_element_types, :LLVMCountStructElementTypes, [:pointer], :uint
    attach_function :get_struct_element_types, :LLVMGetStructElementTypes, [:pointer, :pointer], :void
    attach_function :is_packed_struct, :LLVMIsPackedStruct, [:pointer], :int
    attach_function :is_opaque_struct, :LLVMIsOpaqueStruct, [:pointer], :int
    attach_function :get_type_by_name, :LLVMGetTypeByName, [:pointer, :string], :pointer
    
    # Array, pointer and vector types (sequence types)
    attach_function :array_type, :LLVMArrayType, [:pointer, :uint], :pointer
    attach_function :pointer_type, :LLVMPointerType, [:pointer, :uint], :pointer
    attach_function :vector_type, :LLVMVectorType, [:pointer, :uint], :pointer
    
    attach_function :get_element_type, :LLVMGetElementType, [:pointer], :pointer
    attach_function :get_array_length, :LLVMGetArrayLength, [:pointer], :uint
    attach_function :get_pointer_address_space, :LLVMGetPointerAddressSpace, [:pointer], :uint
    attach_function :get_vector_size, :LLVMGetVectorSize, [:pointer], :uint
    
    # All other types
    attach_function :void_type_in_context, :LLVMVoidTypeInContext, [:pointer], :pointer
    attach_function :label_type_in_context, :LLVMLabelTypeInContext, [:pointer], :pointer
    
    attach_function :void_type, :LLVMVoidType, [], :pointer
    attach_function :label_type, :LLVMLabelType, [], :pointer
    
    # All values
    attach_function :type_of, :LLVMTypeOf, [:pointer], :pointer
    attach_function :get_value_name, :LLVMGetValueName, [:pointer], :string
    attach_function :set_value_name, :LLVMSetValueName, [:pointer, :string], :void
    attach_function :dump_value, :LLVMDumpValue, [:pointer], :void
    
    # Operations on Users
    attach_function :get_operand, :LLVMGetOperand, [:pointer, :int], :pointer
    attach_function :set_operand, :LLVMSetOperand, [:pointer, :int, :pointer], :void
    attach_function :get_num_operands, :LLVMGetNumOperands, [:pointer], :int

    # Constants of any type
    attach_function :const_null, :LLVMConstNull, [:pointer], :pointer
    attach_function :const_all_ones, :LLVMConstAllOnes, [:pointer], :pointer
    attach_function :get_undef, :LLVMGetUndef, [:pointer], :pointer
    attach_function :is_constant, :LLVMIsConstant, [:pointer], :int
    attach_function :is_null, :LLVMIsNull, [:pointer], :int
    attach_function :is_undef, :LLVMIsUndef, [:pointer], :int
    attach_function :const_pointer_null, :LLVMConstPointerNull, [:pointer], :pointer
    
    # Scalar constants
    attach_function :const_int, :LLVMConstInt, [:pointer, :ulong_long, :int], :pointer
    attach_function :const_int_of_string, :LLVMConstIntOfString, [:pointer, :string, :uint8], :pointer
    attach_function :const_int_of_string_and_size, :LLVMConstIntOfStringAndSize, [:pointer, :string, :uint, :uint8], :pointer
    attach_function :const_real, :LLVMConstReal, [:pointer, :double], :pointer
    attach_function :const_real_of_string, :LLVMConstRealOfString, [:pointer, :string], :pointer
    attach_function :const_real_of_string_and_size, :LLVMConstRealOfStringAndSize, [:pointer, :string, :uint], :pointer
    
    # Composite constants
    attach_function :const_string_in_context, :LLVMConstStringInContext, [:pointer, :string, :uint, :int], :pointer
    attach_function :const_struct_in_context, :LLVMConstStructInContext, [:pointer, :pointer, :uint, :int], :pointer
    
    attach_function :const_string, :LLVMConstString, [:string, :uint, :int], :pointer
    attach_function :const_array, :LLVMConstArray, [:pointer, :pointer, :uint], :pointer
    attach_function :const_struct, :LLVMConstStruct, [:pointer, :uint, :int], :pointer
    attach_function :const_vector, :LLVMConstVector, [:pointer, :uint], :pointer
    
    # Constant expressions
    attach_function :get_const_opcode, :LLVMGetConstOpcode, [:pointer], :opcode
    attach_function :align_of, :LLVMAlignOf, [:pointer], :pointer
    attach_function :size_of, :LLVMSizeOf, [:pointer], :pointer
    attach_function :const_neg, :LLVMConstNeg, [:pointer], :pointer
    attach_function :const_f_neg, :LLVMConstFNeg, [:pointer], :pointer
    attach_function :const_not, :LLVMConstNot, [:pointer], :pointer
    attach_function :const_add, :LLVMConstAdd, [:pointer, :pointer], :pointer
    attach_function :const_nsw_add, :LLVMConstNSWAdd, [:pointer, :pointer], :pointer
    attach_function :const_f_add, :LLVMConstFAdd, [:pointer, :pointer], :pointer
    attach_function :const_sub, :LLVMConstSub, [:pointer, :pointer], :pointer
    attach_function :const_f_sub, :LLVMConstFSub, [:pointer, :pointer], :pointer
    attach_function :const_mul, :LLVMConstMul, [:pointer, :pointer], :pointer
    attach_function :const_f_mul, :LLVMConstFMul, [:pointer, :pointer], :pointer
    attach_function :const_u_div, :LLVMConstUDiv, [:pointer, :pointer], :pointer
    attach_function :const_s_div, :LLVMConstSDiv, [:pointer, :pointer], :pointer
    attach_function :const_exact_s_div, :LLVMConstExactSDiv, [:pointer, :pointer], :pointer
    attach_function :const_f_div, :LLVMConstFDiv, [:pointer, :pointer], :pointer
    attach_function :const_u_rem, :LLVMConstURem, [:pointer, :pointer], :pointer
    attach_function :const_s_rem, :LLVMConstSRem, [:pointer, :pointer], :pointer
    attach_function :const_f_rem, :LLVMConstFRem, [:pointer, :pointer], :pointer
    attach_function :const_and, :LLVMConstAnd, [:pointer, :pointer], :pointer
    attach_function :const_or, :LLVMConstOr, [:pointer, :pointer], :pointer
    attach_function :const_xor, :LLVMConstXor, [:pointer, :pointer], :pointer
    attach_function :const_i_cmp, :LLVMConstICmp, [:int, :pointer, :pointer], :pointer
    attach_function :const_f_cmp, :LLVMConstFCmp, [:int, :pointer, :pointer], :pointer
    attach_function :const_shl, :LLVMConstShl, [:pointer, :pointer], :pointer
    attach_function :const_l_shr, :LLVMConstLShr, [:pointer, :pointer], :pointer
    attach_function :const_a_shr, :LLVMConstAShr, [:pointer, :pointer], :pointer
    attach_function :const_gep, :LLVMConstGEP, [:pointer, :pointer, :uint], :pointer
    attach_function :const_in_bounds_gep, :LLVMConstInBoundsGEP, [:pointer, :pointer, :uint], :pointer
    attach_function :const_trunc, :LLVMConstTrunc, [:pointer, :pointer], :pointer
    attach_function :const_s_ext, :LLVMConstSExt, [:pointer, :pointer], :pointer
    attach_function :const_z_ext, :LLVMConstZExt, [:pointer, :pointer], :pointer
    attach_function :const_fp_trunc, :LLVMConstFPTrunc, [:pointer, :pointer], :pointer
    attach_function :const_fp_ext, :LLVMConstFPExt, [:pointer, :pointer], :pointer
    attach_function :const_ui_to_fp, :LLVMConstUIToFP, [:pointer, :pointer], :pointer
    attach_function :const_si_to_fp, :LLVMConstSIToFP, [:pointer, :pointer], :pointer
    attach_function :const_fp_to_ui, :LLVMConstFPToUI, [:pointer, :pointer], :pointer
    attach_function :const_fp_to_si, :LLVMConstFPToSI, [:pointer, :pointer], :pointer
    attach_function :const_ptr_to_int, :LLVMConstPtrToInt, [:pointer, :pointer], :pointer
    attach_function :const_int_to_ptr, :LLVMConstIntToPtr, [:pointer, :pointer], :pointer
    attach_function :const_bit_cast, :LLVMConstBitCast, [:pointer, :pointer], :pointer
    attach_function :const_z_ext_or_bit_cast, :LLVMConstZExtOrBitCast, [:pointer, :pointer], :pointer
    attach_function :const_s_ext_or_bit_cast, :LLVMConstSExtOrBitCast, [:pointer, :pointer], :pointer
    attach_function :const_trunc_or_bit_cast, :LLVMConstTruncOrBitCast, [:pointer, :pointer], :pointer
    attach_function :const_pointer_cast, :LLVMConstPointerCast, [:pointer, :pointer], :pointer
    attach_function :const_int_cast, :LLVMConstIntCast, [:pointer, :pointer, :uint], :pointer
    attach_function :const_fp_cast, :LLVMConstFPCast, [:pointer, :pointer], :pointer
    attach_function :const_select, :LLVMConstSelect, [:pointer, :pointer, :pointer], :pointer
    attach_function :const_extract_element, :LLVMConstExtractElement, [:pointer, :pointer], :pointer
    attach_function :const_insert_element, :LLVMConstInsertElement, [:pointer, :pointer], :pointer
    attach_function :const_shuffle_vector, :LLVMConstShuffleVector, [:pointer, :pointer, :pointer], :pointer
    attach_function :const_extract_value, :LLVMConstExtractValue, [:pointer, :pointer, :uint], :pointer
    attach_function :const_insert_value, :LLVMConstInsertValue, [:pointer, :pointer, :pointer, :uint], :pointer
    attach_function :const_inline_asm, :LLVMConstInlineAsm, [:pointer, :string, :string, :int], :pointer
    
    # Global variables, functions and aliases (globals)
    attach_function :get_global_parent, :LLVMGetGlobalParent, [:pointer], :pointer
    attach_function :is_declaration, :LLVMIsDeclaration, [:pointer], :int
    attach_function :get_linkage, :LLVMGetLinkage, [:pointer], :linkage
    attach_function :set_linkage, :LLVMSetLinkage, [:pointer, :linkage], :void
    attach_function :get_section, :LLVMGetSection, [:pointer], :string
    attach_function :set_section, :LLVMSetSection, [:pointer, :string], :void
    attach_function :get_visibility, :LLVMGetVisibility, [:pointer], :visibility
    attach_function :set_visibility, :LLVMSetVisibility, [:pointer, :visibility], :void
    attach_function :get_alignment, :LLVMGetAlignment, [:pointer], :uint
    attach_function :set_alignment, :LLVMSetAlignment, [:pointer, :uint], :void
    
    attach_function :add_global, :LLVMAddGlobal, [:pointer, :pointer, :string], :pointer
    attach_function :get_named_global, :LLVMGetNamedGlobal, [:pointer, :string], :pointer
    attach_function :get_first_global, :LLVMGetFirstGlobal, [:pointer], :pointer
    attach_function :get_last_global, :LLVMGetLastGlobal, [:pointer], :pointer
    attach_function :get_next_global, :LLVMGetNextGlobal, [:pointer], :pointer
    attach_function :get_previous_global, :LLVMGetPreviousGlobal, [:pointer], :pointer
    attach_function :delete_global, :LLVMDeleteGlobal, [:pointer], :void
    attach_function :get_initializer, :LLVMGetInitializer, [:pointer], :pointer
    attach_function :set_initializer, :LLVMSetInitializer, [:pointer, :pointer], :void
    attach_function :is_thread_local, :LLVMIsThreadLocal, [:pointer], :bool
    attach_function :set_thread_local, :LLVMSetThreadLocal, [:pointer, :int], :void
    attach_function :is_global_constant, :LLVMIsGlobalConstant, [:pointer], :bool
    attach_function :set_global_constant, :LLVMSetGlobalConstant, [:pointer, :bool], :void
    
    # Aliases
    attach_function :add_alias, :LLVMAddAlias, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Function operations
    attach_function :add_function, :LLVMAddFunction, [:pointer, :string, :pointer], :pointer
    attach_function :get_named_function, :LLVMGetNamedFunction, [:pointer, :string], :pointer
    attach_function :get_first_function, :LLVMGetFirstFunction, [:pointer], :pointer
    attach_function :get_last_function, :LLVMGetLastFunction, [:pointer], :pointer
    attach_function :get_next_function, :LLVMGetNextFunction, [:pointer], :pointer
    attach_function :get_previous_function, :LLVMGetPreviousFunction, [:pointer], :pointer
    attach_function :delete_function, :LLVMDeleteFunction, [:pointer], :void
    attach_function :get_intrinsic_id, :LLVMGetIntrinsicID, [:pointer], :uint
    attach_function :get_function_call_conv, :LLVMGetFunctionCallConv, [:pointer], :call_conv
    attach_function :set_function_call_conv, :LLVMSetFunctionCallConv, [:pointer, :call_conv], :void
    attach_function :get_gc, :LLVMGetGC, [:pointer], :string
    attach_function :set_gc, :LLVMSetGC, [:pointer, :string], :void
    attach_function :add_function_attr, :LLVMAddFunctionAttr, [:pointer, :attribute], :void
    attach_function :remove_function_attr, :LLVMRemoveFunctionAttr, [:pointer, :attribute], :void
    
    # Parameters
    attach_function :count_params, :LLVMCountParams, [:pointer], :uint
    attach_function :get_params, :LLVMGetParams, [:pointer, :pointer], :void
    attach_function :get_param, :LLVMGetParam, [:pointer, :uint], :pointer
    attach_function :get_param_parent, :LLVMGetParamParent, [:pointer], :pointer
    attach_function :get_first_param, :LLVMGetFirstParam, [:pointer], :pointer
    attach_function :get_last_param, :LLVMGetLastParam, [:pointer], :pointer
    attach_function :get_next_param, :LLVMGetNextParam, [:pointer], :pointer
    attach_function :get_previous_param, :LLVMGetPreviousParam, [:pointer], :pointer
    attach_function :add_attribute, :LLVMAddAttribute, [:pointer, :attribute], :void
    attach_function :remove_attribute, :LLVMRemoveAttribute, [:pointer, :attribute], :void
    attach_function :set_param_alignment, :LLVMSetParamAlignment, [:pointer, :uint], :void
    
    # Basic blocks
    attach_function :basic_block_as_value, :LLVMBasicBlockAsValue, [:pointer], :pointer
    attach_function :value_is_basic_block, :LLVMValueIsBasicBlock, [:pointer], :int
    attach_function :value_as_basic_block, :LLVMValueAsBasicBlock, [:pointer], :pointer
    attach_function :get_basic_block_parent, :LLVMGetBasicBlockParent, [:pointer], :pointer
    attach_function :count_basic_blocks, :LLVMCountBasicBlocks, [:pointer], :uint
    attach_function :get_basic_blocks, :LLVMGetBasicBlocks, [:pointer, :pointer], :void
    attach_function :get_first_basic_block, :LLVMGetFirstBasicBlock, [:pointer], :pointer
    attach_function :get_last_basic_block, :LLVMGetLastBasicBlock, [:pointer], :pointer
    attach_function :get_next_basic_block, :LLVMGetNextBasicBlock, [:pointer], :pointer
    attach_function :get_previous_basic_block, :LLVMGetPreviousBasicBlock, [:pointer], :pointer
    attach_function :get_entry_basic_block, :LLVMGetEntryBasicBlock, [:pointer], :pointer
    
    attach_function :append_basic_block_in_context, :LLVMAppendBasicBlockInContext, [:pointer, :pointer, :string], :pointer
    attach_function :insert_basic_block_in_context, :LLVMInsertBasicBlockInContext, [:pointer, :pointer, :string], :pointer
    
    attach_function :append_basic_block, :LLVMAppendBasicBlock, [:pointer, :string], :pointer
    attach_function :delete_basic_block, :LLVMDeleteBasicBlock, [:pointer], :void
    
    # Instructions
    attach_function :get_instruction_parent, :LLVMGetInstructionParent, [:pointer], :pointer
    attach_function :get_first_instruction, :LLVMGetFirstInstruction, [:pointer], :pointer
    attach_function :get_last_instruction, :LLVMGetLastInstruction, [:pointer], :pointer
    attach_function :get_next_instruction, :LLVMGetNextInstruction, [:pointer], :pointer
    attach_function :get_previous_instruction, :LLVMGetPreviousInstruction, [:pointer], :pointer
    
    # Call sites
    attach_function :set_instruction_call_conv, :LLVMSetInstructionCallConv, [:pointer, :call_conv], :void
    attach_function :get_instruction_call_conv, :LLVMGetInstructionCallConv, [:pointer], :call_conv
    attach_function :add_instr_attribute, :LLVMAddInstrAttribute, [:pointer, :uint, :attribute], :void
    attach_function :remove_instr_attribute, :LLVMRemoveInstrAttribute, [:pointer, :uint, :attribute], :void
    attach_function :set_instr_param_alignment, :LLVMSetInstrParamAlignment, [:pointer, :uint, :uint], :void
    
    # Call instructions
    attach_function :is_tail_call, :LLVMIsTailCall, [:pointer], :int
    attach_function :set_tail_call, :LLVMSetTailCall, [:pointer, :int], :void
    
    # Phi nodes
    attach_function :add_incoming, :LLVMAddIncoming, [:pointer, :pointer, :pointer, :uint], :void
    attach_function :count_incoming, :LLVMCountIncoming, [:pointer], :uint
    attach_function :get_incoming_value, :LLVMGetIncomingValue, [:pointer, :uint], :pointer
    attach_function :get_incoming_block, :LLVMGetIncomingBlock, [:pointer, :uint], :pointer
    
    # Instruction builders
    attach_function :create_builder_in_context, :LLVMCreateBuilderInContext, [:pointer], :pointer
    attach_function :create_builder, :LLVMCreateBuilder, [], :pointer
    attach_function :position_builder, :LLVMPositionBuilder, [:pointer, :pointer, :pointer], :void
    attach_function :position_builder_before, :LLVMPositionBuilderBefore, [:pointer, :pointer], :void
    attach_function :position_builder_at_end, :LLVMPositionBuilderAtEnd, [:pointer, :pointer], :void
    attach_function :get_insert_block, :LLVMGetInsertBlock, [:pointer], :pointer
    attach_function :clear_insertion_position, :LLVMClearInsertionPosition, [:pointer], :void
    attach_function :insert_into_builder, :LLVMInsertIntoBuilder, [:pointer, :pointer], :void
    attach_function :insert_into_builder_with_name, :LLVMInsertIntoBuilderWithName, [:pointer, :pointer, :string], :void
    attach_function :dispose_builder, :LLVMDisposeBuilder, [:pointer], :void
    
    # Terminators
    attach_function :build_ret_void, :LLVMBuildRetVoid, [:pointer], :pointer
    attach_function :build_ret, :LLVMBuildRet, [:pointer, :pointer], :pointer
    attach_function :build_aggregate_ret, :LLVMBuildAggregateRet, [:pointer, :pointer, :uint], :pointer
    attach_function :build_br, :LLVMBuildBr, [:pointer, :pointer], :pointer
    attach_function :build_cond_br, :LLVMBuildCondBr, [:pointer, :pointer, :pointer, :pointer], :pointer
    attach_function :build_switch, :LLVMBuildSwitch, [:pointer, :pointer, :pointer, :uint], :pointer
    attach_function :build_invoke, :LLVMBuildInvoke, [:pointer, :pointer, :pointer, :uint, :pointer, :pointer, :string], :pointer
    attach_function :build_unreachable, :LLVMBuildUnreachable, [:pointer], :pointer
    
    # Switch instruction
    attach_function :add_case, :LLVMAddCase, [:pointer, :pointer, :pointer], :void
    
    # Arithmetic
    attach_function :build_add, :LLVMBuildAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_nsw_add, :LLVMBuildNSWAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_f_add, :LLVMBuildFAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_sub, :LLVMBuildSub, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_f_sub, :LLVMBuildFSub, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_mul, :LLVMBuildMul, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_f_mul, :LLVMBuildFMul, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_u_div, :LLVMBuildUDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_s_div, :LLVMBuildSDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_exact_s_div, :LLVMBuildExactSDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_f_div, :LLVMBuildFDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_u_rem, :LLVMBuildURem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_s_rem, :LLVMBuildSRem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_f_rem, :LLVMBuildFRem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_shl, :LLVMBuildShl, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_l_shr, :LLVMBuildLShr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_a_shr, :LLVMBuildAShr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_and, :LLVMBuildAnd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_or, :LLVMBuildOr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_xor, :LLVMBuildXor, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_neg, :LLVMBuildNeg, [:pointer, :pointer, :string], :pointer
    attach_function :build_not, :LLVMBuildNot, [:pointer, :pointer, :string], :pointer
    
    # Memory
    attach_function :build_malloc, :LLVMBuildMalloc, [:pointer, :pointer, :string], :pointer
    attach_function :build_array_malloc, :LLVMBuildArrayMalloc, [:pointer, :pointer, :pointer, :string], :string
    attach_function :build_alloca, :LLVMBuildAlloca, [:pointer, :pointer, :string], :pointer
    attach_function :build_array_alloca, :LLVMBuildArrayAlloca, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_free, :LLVMBuildFree, [:pointer, :pointer], :pointer
    attach_function :build_load, :LLVMBuildLoad, [:pointer, :pointer, :string], :pointer
    attach_function :build_store, :LLVMBuildStore, [:pointer, :pointer, :pointer], :pointer
    attach_function :build_gep, :LLVMBuildGEP, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :build_in_bounds_gep, :LLVMBuildInBoundsGEP, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :build_struct_gep, :LLVMBuildStructGEP, [:pointer, :pointer, :uint, :string], :pointer
    attach_function :build_global_string, :LLVMBuildGlobalString, [:pointer, :string, :string], :pointer
    attach_function :build_global_string_ptr, :LLVMBuildGlobalStringPtr, [:pointer, :string, :string], :pointer
    
    # Casts
    attach_function :build_trunc, :LLVMBuildTrunc, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_z_ext, :LLVMBuildZExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_s_ext, :LLVMBuildSExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_fp_to_ui, :LLVMBuildFPToUI, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_fp_to_si, :LLVMBuildFPToSI, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_ui_to_fp, :LLVMBuildUIToFP, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_si_to_fp, :LLVMBuildSIToFP, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_fp_trunc, :LLVMBuildFPTrunc, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_fp_ext, :LLVMBuildFPExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_ptr_to_int, :LLVMBuildPtrToInt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_int_to_ptr, :LLVMBuildIntToPtr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_bit_cast, :LLVMBuildBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_z_ext_or_bit_cast, :LLVMBuildZExtOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_s_ext_or_bit_cast, :LLVMBuildSExtOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_trunc_or_bit_cast, :LLVMBuildTruncOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_pointer_cast, :LLVMBuildPointerCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_int_cast, :LLVMBuildIntCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_fp_cast, :LLVMBuildFPCast, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Comparisons
    attach_function :build_i_cmp, :LLVMBuildICmp, [:pointer, :int_predicate, :pointer, :pointer, :string], :pointer
    attach_function :build_f_cmp, :LLVMBuildFCmp, [:pointer, :real_predicate, :pointer, :pointer, :string], :pointer
    
    # Misc
    attach_function :build_phi, :LLVMBuildPhi, [:pointer, :pointer, :string], :pointer
    attach_function :build_call, :LLVMBuildCall, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :build_select, :LLVMBuildSelect, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_va_arg, :LLVMBuildVAArg, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_extract_element, :LLVMBuildExtractElement, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_insert_element, :LLVMBuildInsertElement, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_shuffle_vector, :LLVMBuildShuffleVector, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :build_extract_value, :LLVMBuildExtractValue, [:pointer, :pointer, :uint, :string], :pointer
    attach_function :build_insert_value, :LLVMBuildInsertValue, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    
    attach_function :build_is_null, :LLVMBuildIsNull, [:pointer, :pointer, :string], :pointer
    attach_function :build_is_not_null, :LLVMBuildIsNotNull, [:pointer, :pointer, :string], :pointer
    attach_function :build_ptr_diff, :LLVMBuildPtrDiff, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Module providers
    attach_function :create_module_provider_for_existing_module, :LLVMCreateModuleProviderForExistingModule, [:pointer], :pointer
    attach_function :dispose_module_provider, :LLVMDisposeModuleProvider, [:pointer], :void
    
    # Memory buffers
    attach_function :create_memory_buffer_with_contents_of_file, :LLVMCreateMemoryBufferWithContentsOfFile, [:string, :pointer, :pointer], :int
    attach_function :create_memory_buffer_with_stdin, :LLVMCreateMemoryBufferWithSTDIN, [:pointer, :pointer], :int
    attach_function :dispose_memory_buffer, :LLVMDisposeMemoryBuffer, [:pointer], :void
    
    # Pass managers
    attach_function :create_pass_manager, :LLVMCreatePassManager, [], :pointer
    attach_function :create_function_pass_manager, :LLVMCreateFunctionPassManager, [:pointer], :pointer
    attach_function :create_function_pass_manager_for_module, :LLVMCreateFunctionPassManagerForModule, [:pointer], :pointer
    attach_function :run_pass_manager, :LLVMRunPassManager, [:pointer, :pointer], :int
    attach_function :initialize_function_pass_manager, :LLVMInitializeFunctionPassManager, [:pointer], :int
    attach_function :run_function_pass_manager, :LLVMRunFunctionPassManager, [:pointer, :pointer], :int
    attach_function :finalize_function_pass_manager, :LLVMFinalizeFunctionPassManager, [:pointer], :int
    attach_function :dispose_pass_manager, :LLVMDisposePassManager, [:pointer], :void
  end
  
  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/pass_manager'
  require 'llvm/core/bitcode'
end
