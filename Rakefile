require 'rake/gempackagetask'
require 'rake/testtask'

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.rcov_opts << "--exclude gems"
    t.test_files = FileList["test/**/*_test.rb"]
  end
rescue LoadError
  warn "Proceeding without Rcov. gem install rcov on supported platforms."
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    yardlib = File.join(File.dirname(__FILE__), "yardlib/llvm.rb")
    t.options = %W[-e #{yardlib}]
    t.files = Dir['lib/**/*.rb']
  end
rescue LoadError
  warn "Yard is not installed. `gem install yard` to build documentation."
end

def spec
  Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    
    s.name = 'ruby-llvm'
    s.version = '2.9.0'
    s.summary = "LLVM bindings for Ruby"
    
    s.add_dependency('ffi', '>= 1.0.0')
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

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]
