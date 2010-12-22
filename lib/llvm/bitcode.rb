module LLVM
  module C
    attach_function :LLVMParseBitcode, [:pointer, :buffer_out, :buffer_out], :int
    attach_function :LLVMParseBitcodeInContext, [:pointer, :pointer, :buffer_out, :buffer_out], :int

    attach_function :LLVMWriteBitcodeToFile, [:pointer, :string], :int
  end

  class Module
    def self.parse_bitcode(memory_buffer)
      mod_ref = FFI::Buffer.new :pointer
      msg_ref = FFI::Buffer.new :pointer
      status = C.LLVMParseBitcode(memory_buffer.to_ptr, mod_ref, msg_ref)
      raise msg_ref.get_pointer(0).get_string(0) if status != 0
      from_ptr(mod_ref.get_pointer(0))
    end

    def write_bitcode(filename)
      status = C.LLVMWriteBitcodeToFile(@ptr, filename.to_str)
      raise "writing #{filename.inspect} failed, status #{status}" if status!=0
    end
  end

  class MemoryBuffer
    class << self
      private :new
    end

    def initialize(ptr)
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def self.create_from_file(path)
      buf_ref = FFI::Buffer.new :pointer
      msg_ref = FFI::Buffer.new :pointer
      failed = C.LLVMCreateMemoryBufferWithContentsOfFile(path, buf_ref, msg_ref)
      raise msg_ref.get_pointer(0).get_string(0) if failed
      new(buf_ref.get_pointer(0))
    end

    def dispose
      C.LLVMDisposeMemoryBuffer(@ptr)
    end
  end
end
