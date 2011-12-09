require 'rails'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new
  end

  initializer 'versionist.configure' do |app|
    Versionist.configure do |config|
      config.vendor_name = app.config.versionist[:vendor_name]
    end
  end
end
