# Generated by ffi_gen. Please do not change this file by hand.

require 'ffi'

module LLVM::C
  extend FFI::Library
  ffi_lib ["libLLVM-3.6.so.1", "LLVM-3.6"]
  
  def self.attach_function(name, *_)
    begin; super; rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end
  
  # (Not documented)
  class OpaquePassManagerBuilder < FFI::Struct
    layout :dummy, :char
  end
  
  # See llvm::PassManagerBuilder.
  # 
  # @method pass_manager_builder_create()
  # @return [OpaquePassManagerBuilder] 
  # @scope class
  attach_function :pass_manager_builder_create, :LLVMPassManagerBuilderCreate, [], OpaquePassManagerBuilder
  
  # (Not documented)
  # 
  # @method pass_manager_builder_dispose(pmb)
  # @param [OpaquePassManagerBuilder] pmb 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_dispose, :LLVMPassManagerBuilderDispose, [OpaquePassManagerBuilder], :void
  
  # See llvm::PassManagerBuilder::OptLevel.
  # 
  # @method pass_manager_builder_set_opt_level(pmb, opt_level)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] opt_level 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_set_opt_level, :LLVMPassManagerBuilderSetOptLevel, [OpaquePassManagerBuilder, :uint], :void
  
  # See llvm::PassManagerBuilder::SizeLevel.
  # 
  # @method pass_manager_builder_set_size_level(pmb, size_level)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] size_level 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_set_size_level, :LLVMPassManagerBuilderSetSizeLevel, [OpaquePassManagerBuilder, :uint], :void
  
  # See llvm::PassManagerBuilder::DisableUnitAtATime.
  # 
  # @method pass_manager_builder_set_disable_unit_at_a_time(pmb, value)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] value 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_set_disable_unit_at_a_time, :LLVMPassManagerBuilderSetDisableUnitAtATime, [OpaquePassManagerBuilder, :int], :void
  
  # See llvm::PassManagerBuilder::DisableUnrollLoops.
  # 
  # @method pass_manager_builder_set_disable_unroll_loops(pmb, value)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] value 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_set_disable_unroll_loops, :LLVMPassManagerBuilderSetDisableUnrollLoops, [OpaquePassManagerBuilder, :int], :void
  
  # See llvm::PassManagerBuilder::DisableSimplifyLibCalls
  # 
  # @method pass_manager_builder_set_disable_simplify_lib_calls(pmb, value)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] value 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_set_disable_simplify_lib_calls, :LLVMPassManagerBuilderSetDisableSimplifyLibCalls, [OpaquePassManagerBuilder, :int], :void
  
  # See llvm::PassManagerBuilder::Inliner.
  # 
  # @method pass_manager_builder_use_inliner_with_threshold(pmb, threshold)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [Integer] threshold 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_use_inliner_with_threshold, :LLVMPassManagerBuilderUseInlinerWithThreshold, [OpaquePassManagerBuilder, :uint], :void
  
  # See llvm::PassManagerBuilder::populateFunctionPassManager.
  # 
  # @method pass_manager_builder_populate_function_pass_manager(pmb, pm)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [FFI::Pointer(PassManagerRef)] pm 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_populate_function_pass_manager, :LLVMPassManagerBuilderPopulateFunctionPassManager, [OpaquePassManagerBuilder, :pointer], :void
  
  # See llvm::PassManagerBuilder::populateModulePassManager.
  # 
  # @method pass_manager_builder_populate_module_pass_manager(pmb, pm)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [FFI::Pointer(PassManagerRef)] pm 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_populate_module_pass_manager, :LLVMPassManagerBuilderPopulateModulePassManager, [OpaquePassManagerBuilder, :pointer], :void
  
  # See llvm::PassManagerBuilder::populateLTOPassManager.
  # 
  # @method pass_manager_builder_populate_lto_pass_manager(pmb, pm, internalize, run_inliner)
  # @param [OpaquePassManagerBuilder] pmb 
  # @param [FFI::Pointer(PassManagerRef)] pm 
  # @param [Integer] internalize 
  # @param [Integer] run_inliner 
  # @return [nil] 
  # @scope class
  attach_function :pass_manager_builder_populate_lto_pass_manager, :LLVMPassManagerBuilderPopulateLTOPassManager, [OpaquePassManagerBuilder, :pointer, :int, :int], :void
  
end
