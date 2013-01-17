require 'find'

module LLVM
  LLVM_VERSION = "3.2"
  RUBY_LLVM_VERSION = "3.2.0.beta.1"
  LLVM_CONFIG = begin
    variants = %W(llvm-config-#{LLVM_VERSION} llvm-config)
    llvm_config = nil
    catch :done do
      paths = ENV['PATH'].split(File::PATH_SEPARATOR).select(&File.method(:directory?))
      Find.find(*paths) do |path|
        if variants.include?(File.basename(path))
          actual_version = `#{path} --version`.chomp
          if LLVM_VERSION == actual_version
            llvm_config = path
            throw(:done)
          end
        end
      end
    end
    llvm_config
  end
end
