require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default, :development) if defined?(Bundler)
require "action_controller/railtie"
require 'rspec'
require 'rspec-rails'
require 'simplecov'
SimpleCov.start do
  add_filter "spec/test-api"
end
require 'versionist'
require 'fileutils'
require 'ap'

RSpec.configure do |config|
  config.mock_with :rspec

  config.after :each do
    # delete spec/tmp/
    tmp_dir = ::File.expand_path('../tmp', __FILE__)
    ::FileUtils.rm_rf(tmp_dir)
  end
end
