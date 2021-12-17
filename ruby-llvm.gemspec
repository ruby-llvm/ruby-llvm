# frozen_string_literal: true

require File.expand_path('lib/llvm/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '2.7'

  s.name         = 'ruby-llvm'
  s.version      = LLVM::RUBY_LLVM_VERSION
  s.summary      = 'LLVM bindings for Ruby'
  s.description  = 'Ruby-LLVM is a Ruby language binding to the LLVM compiler infrastructure library.'
  s.authors      = ['Jesse Johnson', 'Jeremy Voorhis']
  s.email        = ['jesse@hightechsorcery.com', 'jvoorhis@gmail.com']
  s.homepage     = 'http://github.com/ruby-llvm/ruby-llvm'

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*.rb']
  s.files       += %w(ext/ruby-llvm-support/Rakefile ext/ruby-llvm-support/support.cpp)
  s.test_files   = Dir['test/**/*.rb']

  s.extensions   = %w(ext/ruby-llvm-support/Rakefile)

  s.extra_rdoc_files = %w(README.md LICENSE)

  s.add_dependency             'ffi',      '~> 1.13'
  s.add_dependency             'rake',     '>= 12', '< 14'

  s.add_development_dependency 'ffi_gen',  '~> 1.2.0'
  s.add_development_dependency 'minitest', '~> 5.14.1'
  s.add_development_dependency 'minitest-reporters', '~> 1.4.2'
  s.add_development_dependency 'rubocop', '~> 1.22.1'
  s.add_development_dependency 'rubocop-minitest'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'yard', '~> 0.9.8'
end
