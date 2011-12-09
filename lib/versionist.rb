require 'versionist/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3

module Versionist
  class Configuration
    attr_accessor :vendor_name
    attr_accessor :default_version
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.configuration
  end
end
