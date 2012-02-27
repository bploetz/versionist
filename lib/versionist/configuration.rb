module Versionist
  class Configuration
    attr_accessor :versioning_strategies
    attr_accessor :default_version
    attr_accessor :header_versions
    attr_accessor :parameter_versions
    attr_accessor :configured_test_framework

    def initialize
      @versioning_strategies ||= Array.new
      @header_versions ||= Array.new
      @parameter_versions ||= Array.new
    end
  end
end
