require 'rubygems'
require 'rake/testtask'
require_relative 'lib/llvm/version.rb'

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    yardlib   = File.join(File.dirname(__FILE__), "yardlib/llvm.rb")
    t.options = %W[-e #{yardlib} --no-private]
    t.files   = Dir['lib/**/*.rb']
  end
rescue LoadError
  warn "Yard is not installed. `gem install yard' to build documentation."
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :generate_ffi do
  require 'ffi_gen'

  mappings = {
    # Core
    'core_ffi.rb'                 => %w(Core.h),
    'core/bitcode_ffi.rb'         => %w(BitReader.h BitWriter.h),

    # Transformations
    'analysis_ffi.rb'             => %w(Analysis.h),
    'transforms/ipo_ffi.rb'       => %w(Transforms/IPO.h),
    'transforms/scalar_ffi.rb'    => %w(Transforms/Scalar.h),
    'transforms/vectorize_ffi.rb' => %w(Transforms/Vectorize.h),
    'transforms/builder_ffi.rb'   => %w(Transforms/PassManagerBuilder.h),

    # Code generation
    'target_ffi.rb'               => %w(Target.h TargetMachine.h),
    'linker_ffi.rb'               => %w(Linker.h),
    'execution_engine_ffi.rb'     => %w(ExecutionEngine.h),
  }

  mappings.each do |ruby_file, headers|
    FFIGen.generate(
      module_name: 'LLVM::C',
      ffi_lib:     'LLVM-3.2',
      headers:     headers.map { |header| "llvm-c/#{header}" },
      cflags:      `#{LLVM::LLVM_CONFIG} --cflags`.split,
      prefixes:    %w(LLVM),
      blacklist:   %w(LLVMGetMDNodeNumOperands LLVMGetMDNodeOperand
                      LLVMInitializeAllTargetInfos LLVMInitializeAllTargets
                      LLVMInitializeNativeTarget),
      output:      "lib/llvm/#{ruby_file}"
    )
  end
end

task :default => [:test]
