require 'rspec/core/rake_task'

task :default => [:spec]

task :build do
  system "gem build versionist.gemspec"
end

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  files = ['lib/**/*.rb']
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Versionist #{Versionist::VERSION}"
  rdoc.rdoc_files.include('lib/**/*.rb')
end
