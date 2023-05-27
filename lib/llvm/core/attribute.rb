# frozen_string_literal: true

module LLVM
  class Attribute

    include PointerIdentity

    class << self

      def create_enum(kind, value = 0, context = Context.global)
        attr_id = attribute_id(kind)
        ptr = C.create_enum_attribute(context, attr_id, value)
        from_ptr(ptr)
      end

      def create_string(key, value, context = Context.global)
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

    end

    def kind
      return enum_kind if enum?
      return string_kind if string?
      raise
    end

    def value
      return C.get_enum_attribute_value(self) if enum?
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
      return "\"#{kind}\" = \"#{value}\"" if string?
      return "#{kind}(#{value})" if enum?
      super
    end

    private

    def enum_kind_id
      C.get_enum_attribute_kind(self)
    end

    def enum_kind
      Support::C.get_enum_attribute_name_for_kind(enum_kind_id)
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
