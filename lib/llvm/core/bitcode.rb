module LLVM
  # @private
  module C
    attach_function :LLVMParseBitcode, [:pointer, :buffer_out, :buffer_out], :int
    attach_function :LLVMParseBitcodeInContext, [:pointer, :pointer, :buffer_out, :buffer_out], :int
    attach_function :LLVMWriteBitcodeToFile, [:pointer, :string], :int
    attach_function :LLVMWriteBitcodeToFD, [:pointer, :int, :int, :int], :int
  end

  class Module
    # Parse a module from a memory buffer
    # @param [String, LLVM::MemoryBuffer] path_or_memory_buffer
    # @return [LLVM::Module]
    def self.parse_bitcode(path_or_memory_buffer)
      memory_buffer = case path_or_memory_buffer
                      when MemoryBuffer then path_or_memory_buffer
                      else MemoryBuffer.from_file(path_or_memory_buffer)
                      end
      FFI::MemoryPointer.new(:pointer) do |mod_ref|
        FFI::MemoryPointer.new(:pointer) do |msg_ref|
          status = C.LLVMParseBitcode(memory_buffer, mod_ref, msg_ref)
          raise msg_ref.get_pointer(0).get_string(0) if status != 0
          return from_ptr(mod_ref.get_pointer(0))
        end
      end
    end

    # Write bitcode to the given path, IO object or file descriptor
    # @param [String, IO, Integer] path_or_io Pathname, IO object or file descriptor
    # @return [true, false] Success
    def write_bitcode(path_or_io)
      status = if path_or_io.respond_to?(:path)
                 C.LLVMWriteBitcodeToFile(self, path_or_io.path)
               elsif path_or_io.respond_to?(:fileno)
                 C.LLVMWriteBitcodeToFD(self, path_or_io.fileno, 0, 1)
               elsif path_or_io.kind_of?(Integer)
                 C.LLVMWriteBitcodeToFD(self, path_or_io, 0, 1)
               else
                 C.LLVMWriteBitcodeToFile(self, path_or_io.to_str)
               end
      return status == 0
    end
  end

  # @private
  class MemoryBuffer
    private_class_method :new

    # @private
    def initialize(ptr)
      @ptr = ptr
    end

    # @private
    def to_ptr
      @ptr
    end

    # Read the contents of a file into a memory buffer
    # @param [String] path
    # @return [LLVM::MemoryBuffer]
    def self.from_file(path)
      FFI::MemoryPointer.new(:pointer) do |buf_ref|
        FFI::MemoryPointer.new(:pointer) do |msg_ref|
          status = C.LLVMCreateMemoryBufferWithContentsOfFile(path.to_str, buf_ref, msg_ref)
          raise msg_ref.get_pointer(0).get_string(0) if status != 0
          return new(buf_ref.get_pointer(0))
        end
      end
    end

    # Read STDIN into a memory buffer
    # @return [LLVM::MemoryBuffer]
    def self.from_stdin
      FFI::Buffer.new(:pointer) do |buf_ref|
        FFI::Buffer.new(:pointer) do |msg_ref|
          status = C.LLVMCreateMemoryBufferWithSTDIN(buf_ref, msg_ref)
          raise msg_ref.get_pointer(0).get_string(0) if status != 0
          return new(buf_ref.get_pointer(0))
        end
      end
    end

    def dispose
      C.LLVMDisposeMemoryBuffer(@ptr)
    end
  end
end
