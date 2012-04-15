require "action_controller/railtie"
#require "sprockets/railtie"
require 'versionist/railtie'

module TestApi
  class Application < Rails::Application
    config.secret_token = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!hi mom!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    config.root = File.expand_path("../../", __FILE__)
    config.active_support.deprecation = :log
    config.action_controller.logger = nil
    config.logger = Logger.new(STDOUT)
    config.log_level = Logger::Severity::UNKNOWN
    config.action_controller.logger = nil
    config.middleware.delete Rails::Rack::Logger
    config.action_dispatch.show_exceptions = false
  end
end
