require 'versionist/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3

require 'active_support'

module Versionist
  extend ActiveSupport::Autoload

  autoload :Configuration
  autoload :NewApiVersionGenerator, "generators/versionist/new_api_version/new_api_version_generator"
  autoload :NewControllerGenerator, "generators/versionist/new_controller/new_controller_generator"
  autoload :NewPresenterGenerator, "generators/versionist/new_presenter/new_presenter_generator"

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.configuration
  end
end
