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
  
  # Links the source module into the destination module, taking ownership
  # of the source module away from the caller. Optionally returns a
  # human-readable description of any errors that occurred in linking.
  # OutMessage must be disposed with LLVMDisposeMessage. The return value
  # is true if an error occurred, false otherwise.
  # 
  # @method link_modules(dest, src, unused, out_message)
  # @param [FFI::Pointer(ModuleRef)] dest 
  # @param [FFI::Pointer(ModuleRef)] src 
  # @param [Integer] unused 
  # @param [FFI::Pointer(**CharS)] out_message 
  # @return [Integer] 
  # @scope class
  attach_function :link_modules, :LLVMLinkModules, [:pointer, :pointer, :uint, :pointer], :int
  
end
