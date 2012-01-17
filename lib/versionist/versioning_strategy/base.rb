require 'active_support/core_ext/hash/keys'

module Versionist
  module VersioningStrategy
    class Base
      attr_reader :config
      attr_reader :default

      def initialize(config={})
        raise ArgumentError, "you must pass a configuration Hash" if config.nil? || !config.is_a?(Hash)
        @config = config
        @config.symbolize_keys!
        Versionist.configuration.versioning_strategies << self
        raise ArgumentError, "attempt set more than one default api version" if !Versionist.configuration.default_version.nil? && @config.has_key?(:default)
        if @config.has_key?(:default)
          Versionist.configuration.default_version = self
          @default = true
        end
      end

      def default?
        @default
      end
    end
  end
end
