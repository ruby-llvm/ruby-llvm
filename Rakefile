require 'rubygems'
require 'rake/testtask'

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    yardlib = File.join(File.dirname(__FILE__), "yardlib/llvm.rb")
    t.options = %W[-e #{yardlib} --no-private]
    t.files = Dir['lib/**/*.rb']
  end
rescue LoadError
  warn "Yard is not installed. `gem install yard` to build documentation."
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :generate_ffi do
  require 'ffi_gen'

  mappings = {
    ["llvm-c/Core.h"] => "core_ffi.rb",
    ["llvm-c/Analysis.h"] => "analysis_ffi.rb",
    ["llvm-c/ExecutionEngine.h"] => "execution_engine_ffi.rb",
    ["llvm-c/Target.h"] => "target_ffi.rb",
    ["llvm-c/BitReader.h", "llvm-c/BitWriter.h"] => "core/bitcode_ffi.rb",
    ["llvm-c/Transforms/IPO.h"] => "transforms/ipo_ffi.rb",
    ["llvm-c/Transforms/Scalar.h"] => "transforms/scalar_ffi.rb",
  }

  mappings.each do |headers, ruby_file|
    FFIGen.generate(
      :module_name => "LLVM::C",
      :ffi_lib     => "LLVM-3.2",
      :headers     => headers,
      :cflags      => `llvm-config-3.2 --cflags`.split(" "),
      :prefixes    => ["LLVM"],
      :blacklist   => ["LLVMGetMDNodeNumOperands", "LLVMGetMDNodeOperand",
                       "LLVMInitializeAllTargetInfos", "LLVMInitializeAllTargets",
                       "LLVMInitializeNativeTarget"],
      :output      => "lib/llvm/#{ruby_file}"
    )
  end
end

task :default => [:test]
