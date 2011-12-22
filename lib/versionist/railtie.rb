require 'rails/railtie'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new

    initializer 'versionist.configure' do |app|
      Versionist.configure do |config|
        config.versioning_strategy = 'header'
        if app.config.versionist.versioning_strategy
          config.versioning_strategy = app.config.versionist.versioning_strategy
          raise "Invalid value for config.versionist.versioning_strategy" if !config.valid?

          if config.versioning_strategy == 'header'
            if app.config.versionist.vendor_name
              config.vendor_name = app.config.versionist.vendor_name
            else
              raise "Must specify config.versionist.vendor_name if config.versionist.versioning_strategy is set to 'header'."
            end
          end
        end
      end
    end
  end
end
