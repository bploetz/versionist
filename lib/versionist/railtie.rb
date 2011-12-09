require 'rails'

module Versionist
  class Railtie < Rails::Railtie
    config.versionist = ActiveSupport::OrderedOptions.new
  end
end
