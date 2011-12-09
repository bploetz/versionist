require 'rails'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new

    initializer 'versionist.configure' do |app|
      Versionist.configure do |config|
        config.vendor_name = app.config.versionist[:vendor_name]
      end
    end
  end
end
