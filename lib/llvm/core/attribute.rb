# frozen_string_literal: true
# typed: strict

module LLVM
  # wrapper for LLVMAttributeRef
  class Attribute
    include PointerIdentity

    class << self
      #: (String | Symbol) -> Attribute?
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
      #: (?Hash[untyped, untyped]) -> Attribute?
      def memory(opts = {})
        opts = opts.transform_keys(&:to_sym)
        val = bit_value(opts[:argmem]) | (bit_value(opts[:inaccessiblemem]) << 2) | (bit_value(opts[:memory]) << 4)
        enum(:memory, val)
      end

      #: -> Attribute?
      def captures_none
        enum(:captures)
      end

      # create enum attribute with optional value and context
      #: (untyped, ?Integer, ?Context) -> Attribute?
      def enum(kind, value = 0, context = Context.global)
        attr_id = attribute_id(kind)
        ptr = C.create_enum_attribute(context, attr_id, value)
        from_ptr(ptr)
      end

      # create string attribute with key and value
      #: (untyped, untyped, ?Context) -> Attribute?
      def string(key, value, context = Context.global)
        key = key.to_s
        value = value.to_s
        ptr = C.create_string_attribute(context, key, key.size, value, value.size)
        from_ptr(ptr)
      end

      #: -> Integer
      def last_enum
        C.get_last_enum_attribute_kind
      end

      private

      #: (FFI::Pointer) -> Attribute?
      def from_ptr(ptr)
        return if ptr.null?
        val = allocate
        val.instance_variable_set(:@ptr, ptr)
        val
      end

      #: (String | Symbol) -> String
      def attribute_name(attr_name)
        attr_name = attr_name.to_s
        if /_attribute$/.match?(attr_name)
          attr_name.chomp('_attribute').tr('_', '')
        else
          attr_name
        end
      end

      #: (String | Symbol) -> Integer
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
      #: (String | Symbol)-> Integer
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

    #: -> (Integer | String)
    def kind
      return enum_kind if enum?
      return string_kind if string?
      raise
    end

    #: -> (Integer | String)
    def value
      return enum_value if enum?
      return string_value if string?
      raise
    end

    #: -> bool
    def enum?
      C.is_enum_attribute(self)
    end

    #: -> bool
    def string?
      C.is_string_attribute(self)
    end

    #: -> bool
    def type?
      C.is_type_attribute(self)
    end

    #: -> String
    def inspect
      to_s
    end

    #: -> String
    def to_s
      Support::C.get_attribute_as_string(self)
    end

    #: -> Integer
    def kind_id
      enum_kind_id
    end

    #: (untyped) -> bool
    def ==(other)
      super if self.class == other.class

      # strings and symbols
      return true if to_s == other.to_s

      false
    end

    #: -> bool
    def readnone?
      enum_kind == 'readnone' || (enum_kind == 'memory' && enum_value_mem_none?)
    end

    #: -> bool
    def readonly?
      enum_kind == 'readonly' || (enum_kind == 'memory' && enum_value_mem_read?)
    end

    #: -> bool
    def writeonly?
      enum_kind == 'writeonly' || (enum_kind == 'memory' && enum_value_mem_write?)
    end

    private

    #: -> bool
    def enum_value_mem_none?
      enum_value.nobits?(63)
    end

    #: -> bool
    def enum_value_mem_read?
      enum_value.anybits?(21)
    end

    #: -> bool
    def enum_value_mem_write?
      enum_value.anybits?(42)
    end

    #: -> Integer
    def enum_kind_id
      C.get_enum_attribute_kind(self)
    end

    #: -> String
    def enum_kind
      Support::C.get_enum_attribute_name_for_kind(enum_kind_id)
    end

    #: -> Integer
    def enum_value
      C.get_enum_attribute_value(self)
    end

    # wraps get_string_attribute_kind
    #: -> String
    def string_kind
      ret = ''
      FFI::MemoryPointer.new(:uint64) do |size_ptr|
        ret = C.get_string_attribute_kind(self, size_ptr) #: as String
      end
      ret
    end

    # wraps get_string_attribute_value
    #: -> String
    def string_value
      ret = ''
      FFI::MemoryPointer.new(:uint) do |size_ptr|
        ret = C.get_string_attribute_value(self, size_ptr) #: as String
      end
      ret
    end
  end
end
