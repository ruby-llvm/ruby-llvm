require 'bundler/setup'

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

require 'llvm/version'
require 'llvm/config'

YARD::Rake::YardocTask.new do |t|
  yardlib      = File.join(File.dirname(__FILE__), "yardlib/llvm.rb")
  t.options    = %W[-e #{yardlib} --no-private]
  t.files      = Dir['lib/**/*.rb']
end

Rake::TestTask.new do |t|
  t.libs       = %w(test)
  t.test_files = FileList["test/**/*_test.rb"]
end

desc 'Regenerate FFI bindings'
task :generate_ffi do
  require 'ffi_gen'

  mappings = {
    # Core
    'core_ffi.rb'                 => %w(Support.h Core.h),
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
      ffi_lib:     ["libLLVM-#{LLVM::LLVM_VERSION}.so.1",
                    "libLLVM.so.#{LLVM::LLVM_VERSION}",
                    "LLVM-#{LLVM::LLVM_VERSION}"],
      headers:     headers.map { |header| "llvm-c/#{header}" },
      cflags:      LLVM::CONFIG::CFLAGS.split(/\s/),
      prefixes:    %w(LLVM),
      output:      "lib/llvm/#{ruby_file}"
    )
  end
end

task :default => [:test]
