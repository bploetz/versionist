require 'active_support/dependencies/autoload'

module Versionist
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :NewApiVersionGenerator, "generators/new_api_version/new_api_version_generator"
  autoload :NewControllerGenerator, "generators/new_controller/new_controller_generator"
  autoload :NewPresenterGenerator, "generators/new_presenter/new_presenter_generator"
  autoload :VersioningStrategy, "versionist/versioning_strategy"
  autoload :Middleware
  autoload :Routing

  def self.configuration
    @@configuration ||= Configuration.new
  end
end

require 'versionist/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3
