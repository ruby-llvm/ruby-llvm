require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rcov/rcovtask'

Rake::RDocTask.new do |t|
  t.rdoc_files   = Dir['lib/**/*.rb']
end

def spec
  Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    
    s.name = 'ruby-llvm'
    s.version = '2.7.0'
    s.summary = "LLVM bindings for Ruby"
    
    s.add_dependency('ffi', '>= 0.5.4')
    s.files = Dir['lib/**/*rb']
    s.require_path = 'lib'
    
    s.has_rdoc = true
    s.extra_rdoc_files = 'README.rdoc'
    
    s.author = "Jeremy Voorhis"
    s.email = "jvoorhis@gmail.com"
    s.homepage = "http://github.com/jvoorhis/ruby-llvm"
  end
end

Rake::GemPackageTask.new(spec) do |t|
end

Rcov::RcovTask.new do |t|
  t.libs << "test"
  t.rcov_opts << "--exclude gems"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]