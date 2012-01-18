require 'rails/railtie'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new

    initializer 'versionist.configure' do |app|
      ActionDispatch::Routing::Mapper.send :include, Versionist::Routing
    end

    config.app_middleware.use Versionist::Middleware
  end
end
