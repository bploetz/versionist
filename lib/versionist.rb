require 'versionist/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3

require 'active_support'

module Versionist
  extend ActiveSupport::Autoload

  autoload :Configuration  

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.configuration
  end
end
