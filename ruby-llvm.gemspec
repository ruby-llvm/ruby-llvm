require File.join(File.dirname(__FILE__), "lib/llvm/version")

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name         = "ruby-llvm"
  s.version      = LLVM::RUBY_LLVM_VERSION
  s.summary      = "LLVM bindings for Ruby"
  s.description  = s.summary
  s.author       = "Jeremy Voorhis"
  s.email        = "jvoorhis@gmail.com"
  s.homepage     = "http://github.com/jvoorhis/ruby-llvm"

  s.require_path = "lib"
  s.files        = Dir["lib/**/*rb"] + Dir["ext/**/*"]
  s.test_files   = Dir["test/**/*.rb"]

  s.has_rdoc = true
  s.extra_rdoc_files = "README.rdoc"

  s.extensions << "ext/ruby-llvm-support/Rakefile"

  s.add_dependency             "ffi", ">= 1.0.0"

  s.add_development_dependency "ffi_gen", ">= 1.1.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "yard"
end
