require 'rails'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new

    initializer 'versionist.configure' do |app|
      Versionist.configure do |config|
        config.versioning_scheme = 'header'
        if app.config.versionist.versioning_scheme
          config.versioning_scheme = app.config.versionist.versioning_scheme
          raise "Invalid value for config.versionist.versioning_scheme." if !config.valid?

          if config.versioning_scheme == 'header'
            if app.config.versionist.vendor_name
              config.vendor_name = app.config.versionist.vendor_name
            else
              raise "Must specify config.versionist.vendor_name if config.versionist.versioning_scheme is set to 'header'."
            end
          end
        end
      end
    end
  end
end
