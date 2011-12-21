require 'rubygems'
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

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]
