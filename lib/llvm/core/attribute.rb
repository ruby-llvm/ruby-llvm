# frozen_string_literal: true

module LLVM
  # wrapper for LLVMAttributeRef
  class Attribute
    include PointerIdentity

    class << self
      def new(from)
        case from
        when String, Symbol
          enum(from)
        else
          raise "Not implemented to create Attribute from #{from.class}"
        end
      end

      # create a memory attribute from a hash where the keys are:
      #   argmem, inaccessiblemem, memory
      # and the valid values are:
      #   read, write, readwrite
      def memory(opts = {})
        opts = opts.transform_keys(&:to_sym)
        val = bit_value(opts[:argmem]) | (bit_value(opts[:inaccessiblemem]) << 2) | (bit_value(opts[:memory]) << 4)
        enum(:memory, val)
      end

      # create enum attribute with optional value and context
      def enum(kind, value = 0, context = Context.global)
        attr_id = attribute_id(kind)
        ptr = C.create_enum_attribute(context, attr_id, value)
        from_ptr(ptr)
      end

      # create string attribute with key and value
      def string(key, value, context = Context.global)
        key = key.to_s
        value = value.to_s
        ptr = C.create_string_attribute(context, key, key.size, value, value.size)
        from_ptr(ptr)
      end

      def last_enum
        C.get_last_enum_attribute_kind
      end

      private

      def from_ptr(ptr)
        return if ptr.null?
        val = allocate
        val.instance_variable_set(:@ptr, ptr)
        val
      end

      def attribute_name(attr_name)
        attr_name = attr_name.to_s
        if /_attribute$/.match?(attr_name)
          attr_name.chomp('_attribute').tr('_', '')
        else
          attr_name
        end
      end

      def attribute_id(attr_name)
        attr_mem = FFI::MemoryPointer.from_string(attribute_name(attr_name))
        attr_kind_id = C.get_enum_attribute_kind_for_name(attr_mem, attr_mem.size - 1)

        raise "No attribute named: #{attr_name}" if attr_kind_id.zero?
        attr_kind_id
      end

      # returns correct 2 bits of memory value:
      #   0 = none
      #   1 = read
      #   2 = write
      #   3 = readwrite
      def bit_value(maybe_value)
        case maybe_value.to_s
        when 'read'
          1
        when 'write'
          2
        when 'readwrite'
          3
        else
          0
        end
      end
    end

    def kind
      return enum_kind if enum?
      return string_kind if string?
      raise
    end

    def value
      return enum_value if enum?
      return string_value if string?
      raise
    end

    def enum?
      C.is_enum_attribute(self)
    end

    def string?
      C.is_string_attribute(self)
    end

    def type?
      C.is_type_attribute(self)
    end

    def inspect
      to_s
    end

    def to_s
      Support::C.get_attribute_as_string(self)
    end

    def kind_id
      enum_kind_id
    end

    def ==(other)
      super if self.class == other.class

      # strings and symbols
      return true if to_s == other.to_s

      false
    end

    def readnone?
      enum_kind == 'readnone' || (enum_kind == 'memory' && enum_value_mem_none?)
    end

    def readonly?
      enum_kind == 'readonly' || (enum_kind == 'memory' && enum_value_mem_read?)
    end

    def writeonly?
      enum_kind == 'writeonly' || (enum_kind == 'memory' && enum_value_mem_write?)
    end

    private

    def enum_value_mem_none?
      (enum_value & 63).zero?
    end

    def enum_value_mem_read?
      (enum_value & 21) != 0
    end

    def enum_value_mem_write?
      (enum_value & 42) != 0
    end

    def enum_kind_id
      C.get_enum_attribute_kind(self)
    end

    def enum_kind
      Support::C.get_enum_attribute_name_for_kind(enum_kind_id)
    end

    def enum_value
      C.get_enum_attribute_value(self)
    end

    # wraps get_string_attribute_kind
    def string_kind
      FFI::MemoryPointer.new(:uint64) do |size_ptr|
        return C.get_string_attribute_kind(self, size_ptr)
      end
    end

    # wraps get_string_attribute_value
    def string_value
      FFI::MemoryPointer.new(:uint) do |size_ptr|
        return C.get_string_attribute_value(self, size_ptr)
      end
    end
  end
end
