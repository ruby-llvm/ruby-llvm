require 'llvm'

module LLVM
  module C
    ffi_lib 'LLVMCore'
    
    LLVMAttribute = [
      LLVMZExtAttribute            = 1 <<  0,
      LLVMSExtAttribute            = 1 <<  1,
      LLVMNoReturnAttribute        = 1 <<  2,
      LLVMInRegAttribute           = 1 <<  3,
      LLVMStructRetAttribute       = 1 <<  4,
      LLVMNoUnwindAttribute        = 1 <<  5,
      LLVMNoAliasAttribute         = 1 <<  6,
      LLVMByValAttribute           = 1 <<  7,
      LLVMNestAttribute            = 1 <<  8,
      LLVMReadNoneAttribute        = 1 <<  9,
      LLVMReadOnlyAttribute        = 1 << 10,
      LLVMNoInlineAttribute        = 1 << 11,
      LLVMAlwaysInlineAttribute    = 1 << 12,
      LLVMOptimizeForSizeAttribute = 1 << 13,
      LLVMStackProtectAttribute    = 1 << 14,
      LLVMStackProtectReqAttribute = 1 << 15,
      LLVMNoCaptureAttribute       = 1 << 21,
      LLVMNoRedZoneAttribute       = 1 << 22,
      LLVMNoImplicitFloatAttribute = 1 << 23,
      LLVMNakedAttribute           = 1 << 24
    ]
    
    LLVM_TYPE_KIND = [
      LLVMVoidTypeKind      =  0,
      LLVMFloatTypeKind     =  1,
      LLVMDoubleTypeKind    =  2,
      LLVMX86_FP80TypeKind  =  3,
      LLVMFP128TypeKind     =  4,
      LLVMPPC_FP128TypeKind =  5,
      LLVMLabelTypeKind     =  6,
      LLVMIntegerTypeKind   =  7,
      LLVMFunctionTypeKind  =  8,
      LLVMStructTypeKind    =  9,
      LLVMArrayTypeKind     = 10,
      LLVMPointerTypeKind   = 11,
      LLVMOpaqueTypeKind    = 12,
      LLVMVectorTypeKind    = 13,
      LLVMMetadataTypeKind  = 14
    ]
    
    LLVM_LINKAGE = [
      LLVMExternalLinkage            =  0,
      LLVMAvailableExternallyLinkage =  1,
      LLVMLinkOnceAnyLinkage         =  2,
      LLVMLinkOnceODRLinkage         =  3,
      LLVMWeakAnyLinkage             =  4,
      LLVMWeakODRLinkage             =  5,
      LLVMAppendingLinkage           =  6,
      LLVMInternalLinkage            =  7,
      LLVMPrivateLinkage             =  8,
      LLVMDLLImportLinkage           =  9,
      LLVMDLLExportLinkage           = 10,
      LLVMExternalWeakLinkage        = 11,
      LLVMGhostLinkage               = 12,
      LLVMCommonLinkage              = 13,
      LLVMLinkerPrivateLinkage       = 14
    ]
    
    LLVM_VISIBILITY = [
      LLVMDefaultVisibility   = 0,
      LLVMHiddenVisibility    = 1,
      LLVMProtectedVisibility = 2
    ]
    
    LLVM_CALL_CONV = [
      LLVMCCallConv           =  0,
      LLVMFastCallConv        =  8,
      LLVMColdCallConv        =  9,
      LLVMX86StdcallCallConv  = 64,
      LLVMX86FastcallCallConv = 65
    ]
    
    LLVM_INT_PREDICATE = [
      LLVMIntEQ  = 32,
      LLVMIntNE  = 33,
      LLVMIntUGT = 34,
      LLVMIntUGE = 35,
      LLVMIntULT = 36,
      LLVMIntULE = 37,
      LLVMIntSGT = 38,
      LLVMIntSGE = 39,
      LLVMIntSLT = 40,
      LLVMIntSLE = 41
    ]
    
    LLVM_REAL_PREDICATE = [
      LLVMRealPredicateFalse =  0,
      LLVMRealOEQ            =  1,
      LLVMRealOGT            =  2,
      LLVMRealOGE            =  3,
      LLVMRealOLT            =  4,
      LLVMRealOLE            =  5,
      LLVMRealONE            =  6,
      LLVMRealORD            =  7,
      LLVMRealUNO            =  8,
      LLVMRealUEQ            =  9,
      LLVMRealUGT            = 10,
      LLVMRealUGE            = 11,
      LLVMRealULT            = 12,
      LLVMRealULE            = 13,
      LLVMRealUNE            = 14,
      LLVMRealPredicateTrue  = 15
    ]
    
    # Error handling
    attach_function :LLVMDisposeMessage, [:pointer], :void
    
    # Contexts
    attach_function :LLVMContextCreate, [], :pointer
    attach_function :LLVMGetGlobalContext, [], :pointer
    attach_function :LLVMContextDispose, [:pointer], :void
    
    # Modules
    attach_function :LLVMModuleCreateWithName, [:string], :pointer
    attach_function :LLVMModuleCreateWithNameInContext, [:string, :pointer], :pointer
    attach_function :LLVMDisposeModule, [:pointer], :void
    attach_function :LLVMGetDataLayout, [:pointer], :string
    attach_function :LLVMSetDataLayout, [:pointer, :string], :void
    attach_function :LLVMGetTarget, [:pointer], :string
    attach_function :LLVMSetTarget, [:pointer, :string], :void
    attach_function :LLVMAddTypeName, [:pointer, :string, :pointer], :int
    attach_function :LLVMDeleteTypeName, [:pointer, :string], :void
    attach_function :LLVMGetTypeByName, [:pointer, :string], :pointer
    attach_function :LLVMDumpModule, [:pointer], :void
    
    # Types
    attach_function :LLVMGetTypeKind, [:pointer], :int
    attach_function :LLVMGetTypeContext, [:pointer], :pointer
    
    # Integer types
    attach_function :LLVMInt1TypeInContext, [:pointer], :pointer
    attach_function :LLVMInt8TypeInContext, [:pointer], :pointer
    attach_function :LLVMInt16TypeInContext, [:pointer], :pointer
    attach_function :LLVMInt32TypeInContext, [:pointer], :pointer
    attach_function :LLVMInt64TypeInContext, [:pointer], :pointer
    attach_function :LLVMIntTypeInContext, [:pointer, :uint], :pointer
    
    attach_function :LLVMInt1Type, [], :pointer
    attach_function :LLVMInt8Type, [], :pointer
    attach_function :LLVMInt16Type, [], :pointer
    attach_function :LLVMInt32Type, [], :pointer
    attach_function :LLVMInt64Type, [], :pointer
    attach_function :LLVMIntType, [:uint], :pointer
    attach_function :LLVMGetIntTypeWidth, [:pointer], :uint
    
    # Real types
    attach_function :LLVMFloatTypeInContext, [:pointer], :pointer
    attach_function :LLVMDoubleTypeInContext, [:pointer], :pointer
    attach_function :LLVMX86FP80TypeInContext, [:pointer], :pointer
    attach_function :LLVMFP128TypeInContext, [:pointer], :pointer
    attach_function :LLVMPPCFP128TypeInContext, [:pointer], :pointer
    
    attach_function :LLVMFloatType, [], :pointer
    attach_function :LLVMDoubleType, [], :pointer
    attach_function :LLVMX86FP80Type, [], :pointer
    attach_function :LLVMFP128Type, [], :pointer
    attach_function :LLVMPPCFP128Type, [], :pointer
    
    # Function types
    attach_function :LLVMFunctionType, [:pointer, :pointer, :uint, :int], :pointer
    attach_function :LLVMIsFunctionVarArg, [:pointer], :int
    attach_function :LLVMGetReturnType, [:pointer], :pointer
    attach_function :LLVMCountParamTypes, [:pointer], :uint
    attach_function :LLVMGetParamTypes, [:pointer, :pointer], :void
    
    # Struct types
    attach_function :LLVMStructTypeInContext, [:pointer, :pointer, :uint, :int], :pointer
    attach_function :LLVMStructType, [:pointer, :uint, :int], :pointer
    attach_function :LLVMCountStructElementTypes, [:pointer], :uint
    attach_function :LLVMGetStructElementTypes, [:pointer, :pointer], :void
    attach_function :LLVMIsPackedStruct, [:pointer], :int
    
    # Array, pointer and vector types (sequence types)
    attach_function :LLVMArrayType, [:pointer, :uint], :pointer
    attach_function :LLVMPointerType, [:pointer, :uint], :pointer
    attach_function :LLVMVectorType, [:pointer, :uint], :pointer
    
    attach_function :LLVMGetElementType, [:pointer], :pointer
    attach_function :LLVMGetArrayLength, [:pointer], :uint
    attach_function :LLVMGetPointerAddressSpace, [:pointer], :uint
    attach_function :LLVMGetVectorSize, [:pointer], :uint
    
    # All other types
    attach_function :LLVMVoidTypeInContext, [:pointer], :pointer
    attach_function :LLVMLabelTypeInContext, [:pointer], :pointer
    attach_function :LLVMOpaqueTypeInContext, [:pointer], :pointer
    
    attach_function :LLVMVoidType, [], :pointer
    attach_function :LLVMLabelType, [], :pointer
    attach_function :LLVMOpaqueType, [], :pointer
    
    # Type handles
    attach_function :LLVMCreateTypeHandle, [:pointer], :pointer
    attach_function :LLVMRefineType, [:pointer, :pointer], :void
    attach_function :LLVMResolveTypeHandle, [:pointer], :pointer
    attach_function :LLVMDisposeTypeHandle, [:pointer], :void
    
    # All values
    attach_function :LLVMTypeOf, [:pointer], :pointer
    attach_function :LLVMGetValueName, [:pointer], :string
    attach_function :LLVMSetValueName, [:pointer, :string], :void
    attach_function :LLVMDumpValue, [:pointer], :void
    
    # Constants of any type
    attach_function :LLVMConstNull, [:pointer], :pointer
    attach_function :LLVMConstAllOnes, [:pointer], :pointer
    attach_function :LLVMGetUndef, [:pointer], :pointer
    attach_function :LLVMIsConstant, [:pointer], :int
    attach_function :LLVMIsNull, [:pointer], :int
    attach_function :LLVMIsUndef, [:pointer], :int
    attach_function :LLVMConstPointerNull, [:pointer], :pointer
    
    # Scalar constants
    attach_function :LLVMConstInt, [:pointer, :ulong_long, :int], :pointer
    attach_function :LLVMConstIntOfString, [:pointer, :string, :uint8], :pointer
    attach_function :LLVMConstIntOfStringAndSize, [:pointer, :string, :uint, :uint8], :pointer
    attach_function :LLVMConstReal, [:pointer, :double], :pointer
    attach_function :LLVMConstRealOfString, [:pointer, :string], :pointer
    attach_function :LLVMConstRealOfStringAndSize, [:pointer, :string, :uint], :pointer
    
    # Composite constants
    attach_function :LLVMConstStringInContext, [:pointer, :string, :uint, :int], :pointer
    attach_function :LLVMConstStructInContext, [:pointer, :pointer, :uint, :int], :pointer
    
    attach_function :LLVMConstString, [:string, :uint, :int], :pointer
    attach_function :LLVMConstArray, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstStruct, [:pointer, :uint, :int], :pointer
    attach_function :LLVMConstVector, [:pointer, :uint], :pointer
    
    # Constant expressions
    attach_function :LLVMAlignOf, [:pointer], :pointer
    attach_function :LLVMSizeOf, [:pointer], :pointer
    attach_function :LLVMConstNeg, [:pointer], :pointer
    attach_function :LLVMConstFNeg, [:pointer], :pointer
    attach_function :LLVMConstNot, [:pointer], :pointer
    attach_function :LLVMConstAdd, [:pointer, :pointer], :pointer
    attach_function :LLVMConstNSWAdd, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFAdd, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSub, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFSub, [:pointer, :pointer], :pointer
    attach_function :LLVMConstMul, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFMul, [:pointer, :pointer], :pointer
    attach_function :LLVMConstUDiv, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSDiv, [:pointer, :pointer], :pointer
    attach_function :LLVMConstExactSDiv, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFDiv, [:pointer, :pointer], :pointer
    attach_function :LLVMConstURem, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSRem, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFRem, [:pointer, :pointer], :pointer
    attach_function :LLVMConstAnd, [:pointer, :pointer], :pointer
    attach_function :LLVMConstOr, [:pointer, :pointer], :pointer
    attach_function :LLVMConstXor, [:pointer, :pointer], :pointer
    attach_function :LLVMConstICmp, [:int, :pointer, :pointer], :pointer
    attach_function :LLVMConstFCmp, [:int, :pointer, :pointer], :pointer
    attach_function :LLVMConstShl, [:pointer, :pointer], :pointer
    attach_function :LLVMConstLShr, [:pointer, :pointer], :pointer
    attach_function :LLVMConstAShr, [:pointer, :pointer], :pointer
    attach_function :LLVMConstGEP, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstInBoundsGEP, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstTrunc, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSExt, [:pointer, :pointer], :pointer
    attach_function :LLVMConstZExt, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFPTrunc, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFPExt, [:pointer, :pointer], :pointer
    attach_function :LLVMConstUIToFP, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSIToFP, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFPToUI, [:pointer, :pointer], :pointer
    attach_function :LLVMConstFPToSI, [:pointer, :pointer], :pointer
    attach_function :LLVMConstPtrToInt, [:pointer, :pointer], :pointer
    attach_function :LLVMConstIntToPtr, [:pointer, :pointer], :pointer
    attach_function :LLVMConstBitCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstZExtOrBitCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSExtOrBitCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstTruncOrBitCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstPointerCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstIntCast, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstFPCast, [:pointer, :pointer], :pointer
    attach_function :LLVMConstSelect, [:pointer, :pointer, :pointer], :pointer
    attach_function :LLVMConstExtractElement, [:pointer, :pointer], :pointer
    attach_function :LLVMConstInsertElement, [:pointer, :pointer], :pointer
    attach_function :LLVMConstShuffleVector, [:pointer, :pointer, :pointer], :pointer
    attach_function :LLVMConstExtractValue, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstInsertValue, [:pointer, :pointer, :pointer, :uint], :pointer
    attach_function :LLVMConstInlineAsm, [:pointer, :string, :string, :int], :pointer
    
    # Global variables, functions and aliases (globals)
    attach_function :LLVMGetGlobalParent, [:pointer], :pointer
    attach_function :LLVMIsDeclaration, [:pointer], :int
    attach_function :LLVMGetLinkage, [:pointer], :int
    attach_function :LLVMSetLinkage, [:pointer, :int], :void
    attach_function :LLVMGetSection, [:pointer], :string
    attach_function :LLVMSetSection, [:pointer, :string], :void
    attach_function :LLVMGetVisibility, [:pointer], :int
    attach_function :LLVMSetVisibility, [:pointer, :int], :void
    attach_function :LLVMGetAlignment, [:pointer], :uint
    attach_function :LLVMSetAlignment, [:pointer, :uint], :void
    
    attach_function :LLVMAddGlobal, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMGetNamedGlobal, [:pointer, :string], :pointer
    attach_function :LLVMGetFirstGlobal, [:pointer], :pointer
    attach_function :LLVMGetLastGlobal, [:pointer], :pointer
    attach_function :LLVMGetNextGlobal, [:pointer], :pointer
    attach_function :LLVMGetPreviousGlobal, [:pointer], :pointer
    attach_function :LLVMDeleteGlobal, [:pointer], :void
    attach_function :LLVMGetInitializer, [:pointer], :pointer
    attach_function :LLVMSetInitializer, [:pointer, :pointer], :void
    attach_function :LLVMIsThreadLocal, [:pointer, :int], :void
    attach_function :LLVMSetThreadLocal, [:pointer, :int], :void
    attach_function :LLVMIsGlobalConstant, [:pointer], :int
    attach_function :LLVMSetGlobalConstant, [:pointer, :int], :void
    
    # Aliases
    attach_function :LLVMAddAlias, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Function operations
    attach_function :LLVMAddFunction, [:pointer, :string, :pointer], :pointer
    attach_function :LLVMGetNamedFunction, [:pointer, :string], :pointer
    attach_function :LLVMGetFirstFunction, [:pointer], :pointer
    attach_function :LLVMGetLastFunction, [:pointer], :pointer
    attach_function :LLVMGetNextFunction, [:pointer], :pointer
    attach_function :LLVMGetPreviousFunction, [:pointer], :pointer
    attach_function :LLVMDeleteFunction, [:pointer], :pointer
    attach_function :LLVMGetIntrinsicID, [:pointer], :uint
    attach_function :LLVMGetFunctionCallConv, [:pointer], :uint
    attach_function :LLVMSetFunctionCallConv, [:pointer, :uint], :void
    attach_function :LLVMGetGC, [:pointer], :string
    attach_function :LLVMSetGC, [:pointer, :string], :void
    attach_function :LLVMAddFunctionAttr, [:pointer, :int], :void
    attach_function :LLVMRemoveFunctionAttr, [:pointer, :int], :void
    
    # Parameters
    attach_function :LLVMCountParams, [:pointer], :uint
    attach_function :LLVMGetParams, [:pointer, :pointer], :void
    attach_function :LLVMGetParam, [:pointer, :uint], :pointer
    attach_function :LLVMGetParamParent, [:pointer], :pointer
    attach_function :LLVMGetFirstParam, [:pointer], :pointer
    attach_function :LLVMGetLastParam, [:pointer], :pointer
    attach_function :LLVMGetNextParam, [:pointer], :pointer
    attach_function :LLVMGetPreviousParam, [:pointer], :pointer
    attach_function :LLVMAddAttribute, [:pointer, :int], :void
    attach_function :LLVMRemoveAttribute, [:pointer, :int], :void
    attach_function :LLVMSetParamAlignment, [:pointer, :uint], :void
    
    # Basic blocks
    attach_function :LLVMBasicBlockAsValue, [:pointer], :pointer
    attach_function :LLVMValueIsBasicBlock, [:pointer], :int
    attach_function :LLVMValueAsBasicBlock, [:pointer], :pointer
    attach_function :LLVMGetBasicBlockParent, [:pointer], :pointer
    attach_function :LLVMCountBasicBlocks, [:pointer], :uint
    attach_function :LLVMGetBasicBlocks, [:pointer, :pointer], :void
    attach_function :LLVMGetFirstBasicBlock, [:pointer], :pointer
    attach_function :LLVMGetLastBasicBlock, [:pointer], :pointer
    attach_function :LLVMGetNextBasicBlock, [:pointer], :pointer
    attach_function :LLVMGetPreviousBasicBlock, [:pointer], :pointer
    attach_function :LLVMGetEntryBasicBlock, [:pointer], :pointer
    
    attach_function :LLVMAppendBasicBlockInContext, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMInsertBasicBlockInContext, [:pointer, :pointer, :string], :pointer
    
    attach_function :LLVMAppendBasicBlock, [:pointer, :string], :pointer
    attach_function :LLVMDeleteBasicBlock, [:pointer], :void
    
    # Instructions
    attach_function :LLVMGetInstructionParent, [:pointer], :pointer
    attach_function :LLVMGetFirstInstruction, [:pointer], :pointer
    attach_function :LLVMGetLastInstruction, [:pointer], :pointer
    attach_function :LLVMGetNextInstruction, [:pointer], :pointer
    attach_function :LLVMGetPreviousInstruction, [:pointer], :pointer
    
    # Call sites
    attach_function :LLVMSetInstructionCallConv, [:pointer, :uint], :void
    attach_function :LLVMGetInstructionCallConv, [:pointer], :uint
    attach_function :LLVMAddInstrAttribute, [:pointer, :uint, :int], :void
    attach_function :LLVMRemoveInstrAttribute, [:pointer, :uint, :int], :void
    attach_function :LLVMSetInstrParamAlignment, [:pointer, :uint, :uint], :void
    
    # Call instructions
    attach_function :LLVMIsTailCall, [:pointer], :int
    attach_function :LLVMSetTailCall, [:pointer, :int], :void
    
    # Phi nodes
    attach_function :LLVMAddIncoming, [:pointer, :pointer, :pointer, :uint], :void
    attach_function :LLVMCountIncoming, [:pointer], :uint
    attach_function :LLVMGetIncomingValue, [:pointer, :uint], :pointer
    attach_function :LLVMGetIncomingBlock, [:pointer, :uint], :pointer
    
    # Instruction builders
    attach_function :LLVMCreateBuilderInContext, [:pointer], :pointer
    attach_function :LLVMCreateBuilder, [], :pointer
    attach_function :LLVMPositionBuilder, [:pointer, :pointer, :pointer], :void
    attach_function :LLVMPositionBuilderBefore, [:pointer, :pointer], :void
    attach_function :LLVMPositionBuilderAtEnd, [:pointer, :pointer], :void
    attach_function :LLVMGetInsertBlock, [:pointer], :pointer
    attach_function :LLVMClearInsertionPosition, [:pointer], :void
    attach_function :LLVMInsertIntoBuilder, [:pointer, :pointer], :void
    attach_function :LLVMInsertIntoBuilderWithName, [:pointer, :pointer, :string], :void
    attach_function :LLVMDisposeBuilder, [:pointer], :void
    
    # Terminators
    attach_function :LLVMBuildRetVoid, [:pointer], :pointer
    attach_function :LLVMBuildRet, [:pointer, :pointer], :pointer
    attach_function :LLVMBuildAggregateRet, [:pointer, :pointer, :uint], :pointer
    attach_function :LLVMBuildBr, [:pointer, :pointer], :pointer
    attach_function :LLVMBuildCondBr, [:pointer, :pointer, :pointer, :pointer], :pointer
    attach_function :LLVMBuildSwitch, [:pointer, :pointer, :pointer, :uint], :pointer
    attach_function :LLVMBuildInvoke, [:pointer, :pointer, :pointer, :uint, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildUnwind, [:pointer], :pointer
    attach_function :LLVMBuildUnreachable, [:pointer], :pointer
    
    # Switch instruction
    attach_function :LLVMAddCase, [:pointer, :pointer, :pointer], :void
    
    # Arithmetic
    attach_function :LLVMBuildAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildNSWAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFAdd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSub, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFSub, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildMul, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFMul, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildUDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildExactSDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFDiv, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildURem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSRem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFRem, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildShl, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildLShr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildAShr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildAnd, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildOr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildXor, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildNeg, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildNot, [:pointer, :pointer, :string], :pointer
    
    # Memory
    attach_function :LLVMBuildMalloc, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildArrayMalloc, [:pointer, :pointer, :pointer, :string], :string
    attach_function :LLVMBuildAlloca, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildArrayAlloca, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFree, [:pointer, :pointer], :pointer
    attach_function :LLVMBuildLoad, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildStore, [:pointer, :pointer, :pointer], :pointer
    attach_function :LLVMBuildGEP, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :LLVMBuildInBoundsGEP, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :LLVMBuildStructGEP, [:pointer, :pointer, :uint, :string], :pointer
    attach_function :LLVMBuildGlobalString, [:pointer, :string, :string], :pointer
    attach_function :LLVMBuildGlobalStringPtr, [:pointer, :string, :string], :pointer
    
    # Casts
    attach_function :LLVMBuildTrunc, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildZExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFPToUI, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFPToSI, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildUIToFP, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSIToFP, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFPTrunc, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFPExt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildPtrToInt, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildIntToPtr, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildZExtOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildSExtOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildTruncOrBitCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildPointerCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildIntCast, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFPCast, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Comparisons
    attach_function :LLVMBuildICmp, [:pointer, :int, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildFCmp, [:pointer, :int, :pointer, :pointer, :string], :pointer
    
    # Misc
    attach_function :LLVMBuildPhi, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildCall, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    attach_function :LLVMBuildSelect, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildVAArg, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildExtractElement, [:pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildInsertElement, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildShuffleVector, [:pointer, :pointer, :pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildExtractValue, [:pointer, :pointer, :uint, :string], :pointer
    attach_function :LLVMBuildInsertValue, [:pointer, :pointer, :pointer, :uint, :string], :pointer
    
    attach_function :LLVMBuildIsNull, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildIsNotNull, [:pointer, :pointer, :string], :pointer
    attach_function :LLVMBuildPtrDiff, [:pointer, :pointer, :pointer, :string], :pointer
    
    # Module providers
    attach_function :LLVMCreateModuleProviderForExistingModule, [:pointer], :pointer
    attach_function :LLVMDisposeModuleProvider, [:pointer], :void
    
    # Memory buffers
    attach_function :LLVMCreateMemoryBufferWithContentsOfFile, [:string, :pointer, :pointer], :int
    attach_function :LLVMCreateMemoryBufferWithSTDIN, [:pointer, :pointer], :int
    attach_function :LLVMDisposeMemoryBuffer, [:pointer], :void
    
    # Pass managers
    attach_function :LLVMCreatePassManager, [], :pointer
    attach_function :LLVMCreateFunctionPassManager, [:pointer], :pointer
    attach_function :LLVMRunPassManager, [:pointer, :pointer], :int
    attach_function :LLVMInitializeFunctionPassManager, [:pointer], :int
    attach_function :LLVMRunFunctionPassManager, [:pointer, :pointer], :int
    attach_function :LLVMFinalizeFunctionPassManager, [:pointer], :int
    attach_function :LLVMDisposePassManager, [:pointer], :void
  end
  
  module Syntax # :nodoc:
    module_function
    
    # Symbols over LLVM_INT_PREDICATE
    def sym2ipred(pred)
      case pred
        when *C::LLVM_INT_PREDICATE then pred
        when :eq  then C::LLVMIntEQ
        when :ne  then C::LLVMIntNE
        when :gt  then C::LLVMIntUGT
        when :uge then C::LLVMIntUGE
        when :ult then C::LLVMIntULT
        when :ule then C::LLVMIntULE
        when :sgt then C::LLVMIntSGT
        when :sge then C::LLVMIntSGE
        when :slt then C::LLVMIntSLT
        when :sle then C::LLVMIntSLE
      end
    end
    
    # Symbols over LLVM_REAL_PREDICATE
    def sym2rpred(pred)
      case pred
        when *C::LLVM_REAL_PREDICATE then pred
        when :false then C::LLVMRealPredicateFalse
        when :oeq   then C::LLVMRealPredicateOEQ
        when :ogt   then C::LLVMRealPredicateOGT
        when :oge   then C::LLVMRealPredicateOGE
        when :olt   then C::LLVMRealPredicateOLT
        when :ole   then C::LLVMRealPredicateOLE
        when :one   then C::LLVMRealPredicateONE
        when :ord   then C::LLVMRealPredicateORD
        when :uno   then C::LLVMRealPredicateUNO
        when :ueq   then C::LLVMRealPredicateUEQ
        when :ugt   then C::LLVMRealPredicateUGT
        when :uge   then C::LLVMRealPredicateUGE
        when :ult   then C::LLVMRealPredicateULT
        when :ule   then C::LLVMRealPredicateULE
        when :une   then C::LLVMRealPredicateUNE
        when :true  then C::LLVMRealPredicateTrue
      end
    end
  end
  
  class Context
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    # Creates a new Context
    def self.create
      new(C.LLVMContextCreate())
    end
    
    # Obtains a reference to the global Context
    def self.global
      new(C.LLVMGetGlobalContext())
    end
    
    def dispose
      C.LLVMContextDispose(@ptr)
    end
  end
  
  class Module
    class << self
      private :new
    end
    
    def self.from_ptr(ptr)
      ptr.null? ? nil : new(ptr)
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def self.create_with_name(name)
      new(C.LLVMModuleCreateWithName(name))
    end
    
    def self.create_with_name_in_context(name, context)
      new(C.LLVMModuleCreateWithNameInContext(name, context))
    end
    
    def add_function(name, *args) # arg_types, result_type)
      type = case args[0]
        when Type then args[0]
        else Type.function(*args)
      end
      function = Function.from_ptr(C.LLVMAddFunction(self, name.to_s, type))
      
      if block_given?
        params = (0...function.params.size).map { |i| function.params[i] }
        yield function, *params
      end
      
      function
    end
    
    def named_function(name)
      self.class.from_ptr(C.LLVMGetNamedFunction(self, name))
    end
    
    # Print the module's IR to stdout
    def dump
      C.LLVMDumpModule(self)
    end
    
    def dispose
      C.LLVMDisposeModule(@ptr)
    end
  end
  
  class Type
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def size
      Int64.from_ptr(C.LLVMSizeOf(self))
    end
    
    def align
      Int64.from_ptr(C.LLVMAlignOf(self))
    end
    
    def self.from_ptr(ptr)
      ptr.null? ? nil : new(ptr)
    end
    
    def self.array(type, element_count)
      from_ptr(C.LLVMArrayType(type, element_count))
    end
    
    def self.pointer(type, address_space = 0)
      from_ptr(C.LLVMPointerType(type, address_space))
    end
    
    def self.vector(type, element_count)
      from_ptr(C.LLVMVectorType(type, element_count))
    end
    
    def self.function(arg_types, result_type)
      arg_types_ptr = FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * arg_types.size)
      arg_types_ptr.write_array_of_pointer(arg_types)
      from_ptr(C.LLVMFunctionType(result_type, arg_types_ptr, arg_types.size, 0))
    end
  end
  
  class Value
    class << self
      private :new
    end
    
    def initialize(ptr)
      @ptr = ptr
    end
    
    def to_ptr # :nodoc:
      @ptr
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
    
    def self.from_ptr(ptr)
      ptr.null? ? nil : new(ptr)
    end
  end
  
  class Argument < Value
  end
  
  class BasicBlock < Value
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
    include Syntax
    
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
    
    def !@
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
      self.class.from_ptr(C.LLVMConstICmp(sym2ipred(pred), self, rhs))
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
  NATIVE_INT_SIZE = case FFI::Platform::ARCH
    when "x86_64" then 64
    # PPC, other arches?
    else 32
  end
  
  ::LLVM::Int = const_get("Int#{NATIVE_INT_SIZE}")
  
  def Int(val)
    case val
      when LLVM::ConstantInt then val
      when Integer then Int.from_i(val)
    end
  end
  module_function :Int
  
  class ConstantReal < Constant
    include Syntax
    
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
      self.class.from_ptr(C.LLMVConstFCmp(sym2rpred(pred), self, rhs))
    end
  end
  
  class Float < ConstantReal
    def self.type
      Type.from_ptr(C.LLVMFloatType)
    end
  end
  
  class Double < ConstantReal
    def self.type
      Type.from_ptr(C.LLVMDoubleType)
    end
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
  end
  
  class Function < GlobalValue
    def call_conv=(conv)
      conv = case conv
        when *C::LLVM_CALL_CONV then conv
        when :ccall          then C::LLVMCCallConv
        when :fastcall       then C::LLVMFastCallConv
        when :coldcall       then C::LLVMColdCallConv
        when :x86stdcall     then C::LLVMX86StdcallCallConv
        when :x86fastcall    then C::LLVMX86FastcallCallConv
      end
      
      C.LLVMSetFunctionCallConv(self, conv)
      
      conv
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
      
      def append(name)
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
      def initialize(fun)
        @fun = fun
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
  end
  
  class Instruction < Value
  end
  
  class CallInst < Instruction
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
      FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * size) do |vals_ptr|
        vals_ptr.write_array_of_pointer(vals)
        FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * size) do |blocks_ptr|
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
  
  class Builder
    include Syntax
    
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
      Instruction.from_ptr(C.LLVMBuildICmp(self, sym2ipred(pred), lhs, rhs, name))
    end
    
    def fcmp(pred, lhs, rhs, name = "")
      Instruction.from_ptr(C.LLVMBuildFCmp(self, sym2rpred(pred), lhs, rhs, name))
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
      args_ptr = FFI::MemoryPointer.new(FFI::TYPE_POINTER.size * args.size)
      args_ptr.write_array_of_pointer(args)
      Instruction.from_ptr(C.LLVMBuildCall(self, fun, args_ptr, args.size, name))
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
  
  class ModuleProvider
    class << self
      private :new
    end
    
    def initialize(ptr)
      @ptr = ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.for_existing_module(mod)
      new(C.LLVMCreateModuleProviderForExistingModule(mod))
    end
  end
  
  class PassManager
    class << self
      private :new
    end
    
    def initialize(ptr) # :nodoc:
      @ptr = ptr
    end
    
    def self.new_with_execution_engine(engine)
      ptr = C.LLVMCreatePassManager()
      C.LLVMAddTargetData(
        C.LLVMGetExecutionEngineTargetData(engine), ptr)
      new(ptr)
    end
    
    def to_ptr # :nodoc:
      @ptr
    end
    
    def run(mod)
      C.LLVMRunPassManager(self, mod)
    end
  end
end
