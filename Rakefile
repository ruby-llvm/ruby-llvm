require 'rubygems'
require 'rubygems/package_task'
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
    t.options = %W[-e #{yardlib} --no-private]
    t.files = Dir['lib/**/*.rb']
  end
rescue LoadError
  warn "Yard is not installed. `gem install yard` to build documentation."
end

def spec
  Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    
    s.name = 'ruby-llvm'
    s.version = '2.9.2'
    s.summary = "LLVM bindings for Ruby"
    s.description = "LLVM bindings for Ruby"
    s.author = "Jeremy Voorhis"
    s.email = "jvoorhis@gmail.com"
    s.homepage = "http://github.com/jvoorhis/ruby-llvm"

    s.add_dependency('ffi', '>= 1.0.0')
    s.files =
      Dir['lib/**/*rb'] +
      %w(
        ext/ruby-llvm-support/Makefile.am
        ext/ruby-llvm-support/Makefile.in
        ext/ruby-llvm-support/config.guess
        ext/ruby-llvm-support/config.sub
        ext/ruby-llvm-support/configure
        ext/ruby-llvm-support/configure.ac
        ext/ruby-llvm-support/depcomp
        ext/ruby-llvm-support/install-sh
        ext/ruby-llvm-support/libtool
        ext/ruby-llvm-support/ltmain.sh
        ext/ruby-llvm-support/missing
        ext/ruby-llvm-support/src/Makefile.am
        ext/ruby-llvm-support/src/Makefile.in
        ext/ruby-llvm-support/src/support.cpp
      )
    s.require_path = 'lib'
    s.extensions << 'ext/ruby-llvm-support/configure'

    s.test_files = Dir['test/**/*.rb']
    
    s.has_rdoc = true
    s.extra_rdoc_files = 'README.rdoc'
  end
end

Gem::PackageTask.new(spec) do |t|
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]
