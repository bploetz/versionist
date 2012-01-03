require 'rails/railtie'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new

    initializer 'versionist.configure' do |app|
      # Versionist.configure do |config|
      #   config.versioning_strategies = Array.new
      # end
    end

    config.app_middleware.use Versionist::Middleware
  end
end
