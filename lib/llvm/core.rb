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
  
  require 'llvm/core/context'
  require 'llvm/core/module'
  require 'llvm/core/type'
  require 'llvm/core/value'
  require 'llvm/core/builder'
  require 'llvm/core/module_provider'
  require 'llvm/core/pass_manager'
end
