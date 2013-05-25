require File.expand_path('lib/llvm/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name         = 'ruby-llvm'
  s.version      = LLVM::RUBY_LLVM_VERSION
  s.summary      = 'LLVM bindings for Ruby'
  s.description  = 'Ruby-LLVM is a Ruby language binding to the LLVM compiler infrastructure library.'
  s.author       = 'Jeremy Voorhis'
  s.email        = 'jvoorhis@gmail.com'
  s.homepage     = 'http://github.com/jvoorhis/ruby-llvm'

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*.rb']
  s.files       += %w(ext/ruby-llvm-support/Rakefile ext/ruby-llvm-support/support.cpp)
  s.test_files   = Dir['test/**/*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = %w(README.md LICENSE)

  s.extensions << 'ext/ruby-llvm-support/Rakefile'

  s.add_dependency             'rake'
  s.add_dependency             'ffi',      '~> 1.7'

  s.add_development_dependency 'ffi_gen',  '~> 1.1.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard',     '~> 0.8.3'
end
