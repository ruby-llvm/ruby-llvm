class LLVMTagFactory < YARD::Tags::DefaultFactory
  def parse_tag(name, text)
    case name
    when :LLVMinst then inst_tag(text)
    when :LLVMpass then pass_tag(text)
    else
      super
    end
  end

  private

  def inst_tag(text)
    url = "http://llvm.org/docs/LangRef.html#i_#{text}"
    markup = "<a href=\"#{url}\">LLVM Instruction: #{text}</a>"
    YARD::Tags::Tag.new("see", markup)
  end

  def pass_tag(text)
    url = "http://llvm.org/docs/Passes.html##{text}"
    markup = "<a href=\"#{url}\">LLVM Pass: #{text}</a>"
    YARD::Tags::Tag.new("see", markup)
  end
end

YARD::Tags::Library.define_tag "Instruction", :LLVMinst
YARD::Tags::Library.define_tag "Pass", :LLVMpass
YARD::Tags::Library.default_factory = LLVMTagFactory
