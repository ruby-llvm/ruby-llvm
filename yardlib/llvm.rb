class LLVMTagFactory < YARD::Tags::DefaultFactory
  def parse_tag(name, text)
    case name
    when :LLVMinst, :LLVMpass
      url = if name == :LLVMinst
              "http://llvm.org/docs/LangRef.html#i_#{text}"
            elsif name == :LLVMpass
              "http://llvm.org/docs/Passes.html##{text}"
            end
      YARD::Tags::Tag.new("see", "<a href=\"#{url}\">#{url}</a>")
    else
      super
    end
  end
end

YARD::Tags::Library.define_tag "Instruction", :LLVMinst
YARD::Tags::Library.define_tag "Pass", :LLVMpass
YARD::Tags::Library.default_factory = LLVMTagFactory
