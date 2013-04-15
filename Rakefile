GEMFILE_MAP = {"gemfiles/Rails-3.0" => "Rails 3.0", "gemfiles/Rails-3.1" => "Rails 3.1", "gemfiles/Rails-3.2" => "Rails 3.2", "gemfiles/RailsAPI-0.0" => "Rails API 0.0", "gemfiles/Rails-4.0" => "Rails 4.0"}

# To run the tests locally:
#   gem install bundler
#   rake test:all
namespace :test do
  desc "Installs all dependencies"
  task :setup do
    GEMFILE_MAP.each do |gemfile, name|
      puts "Installing gems for testing with #{name} ..."
      sh "env BUNDLE_GEMFILE=#{File.dirname(__FILE__) + '/' + gemfile} bundle install"
    end
  end

  GEMFILE_MAP.each do |gemfile, name|
    desc "Run all tests against #{name}"
    task gemfile.downcase.gsub(/\./, "_") do
      sh "env BUNDLE_GEMFILE=#{gemfile} bundle exec rake"
    end
  end
  task :all=> [:setup] + GEMFILE_MAP.map {|gemfile, name| "test:#{gemfile.downcase.gsub(/\./, "_")}"}
end

require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new
task :default => [:spec]

task :build do
  system "gem build versionist.gemspec"
end

