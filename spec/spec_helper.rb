$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'simplecov'

SimpleCov.start

gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

Bundler.setup(:test) if defined?(Bundler)

require 'versionist'
require 'fileutils'

RSpec.configure do |config|
  config.mock_with :rspec

  config.after :each do
    # delete spec/tmp/
    tmp_dir = ::File.expand_path('../tmp', __FILE__)
    ::FileUtils.rm_rf(tmp_dir)
  end
end
