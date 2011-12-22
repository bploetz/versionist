require 'versionist/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3

require 'active_support'

module Versionist
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :NewApiVersionGenerator, "versionist/generators/new_api_version/new_api_version_generator"
  autoload :NewControllerGenerator, "versionist/generators/new_controller/new_controller_generator"
  autoload :NewPresenterGenerator, "versionist/generators/new_presenter/new_presenter_generator"
  autoload :VersioningStrategy, "versionist/versioning_strategy"
  autoload :Routing

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.configuration
  end
end
