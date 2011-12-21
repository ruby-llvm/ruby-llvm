require File.join(File.dirname(__FILE__), "lib/llvm/version")

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  
  s.name = "ruby-llvm"
  s.version = LLVM::RUBY_LLVM_VERSION
  s.summary = "LLVM bindings for Ruby"
  s.description = "LLVM bindings for Ruby"
  s.author = "Jeremy Voorhis"
  s.email = "jvoorhis@gmail.com"
  s.homepage = "http://github.com/jvoorhis/ruby-llvm"

  s.add_dependency("ffi", ">= 1.0.0")
  s.add_development_dependency("rake")
  s.add_development_dependency("rcov")
  s.add_development_dependency("yard")
  s.files = Dir["lib/**/*rb"] + Dir["ext/**/*"]
  s.require_path = "lib"
  s.extensions << "ext/ruby-llvm-support/Rakefile"

  s.test_files = Dir["test/**/*.rb"]
  
  s.has_rdoc = true
  s.extra_rdoc_files = "README.rdoc"
end
