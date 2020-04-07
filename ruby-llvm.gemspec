require File.expand_path('lib/llvm/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY

  s.name         = 'ruby-llvm'
  s.version      = LLVM::RUBY_LLVM_VERSION
  s.summary      = 'LLVM bindings for Ruby'
  s.description  = 'Ruby-LLVM is a Ruby language binding to the LLVM compiler infrastructure library.'
  s.author       = 'Jeremy Voorhis'
  s.email        = 'jvoorhis@gmail.com'
  s.homepage     = 'http://github.com/ruby-llvm/ruby-llvm'

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*.rb']
  s.files       += %w(ext/ruby-llvm-support/Rakefile ext/ruby-llvm-support/support.cpp)
  s.test_files   = Dir['test/**/*.rb']

  s.extensions   = %w(ext/ruby-llvm-support/Rakefile)

  s.has_rdoc         = 'yard'
  s.extra_rdoc_files = %w(README.md LICENSE)

  s.add_dependency             'ffi',      '~> 1.10.0'
  s.add_dependency             'rake',     '>= 12', '< 14'

  s.add_development_dependency 'ffi_gen',  '~> 1.2.0'
  s.add_development_dependency 'minitest', '~> 5.11.3'
  s.add_development_dependency 'minitest-reporters', '~> 1.3.6'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard', '~> 0.9.8'
end
