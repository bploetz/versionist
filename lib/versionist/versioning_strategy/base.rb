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
        if @config.has_key?(:default)
          @default = true
        else
          @default = false
        end
        if !Versionist.configuration.versioning_strategies.include?(self)
          raise ArgumentError, "[VERSIONIST] attempt to set more than one default api version" if !Versionist.configuration.default_version.nil? && self.default? && Versionist.configuration.default_version != self
          Versionist.configuration.versioning_strategies << self
          Versionist.configuration.default_version = self if self.default?
        end
      end

      def default?
        @default
      end

      def ==(other)
        return false if other.nil? || !other.is_a?(Versionist::VersioningStrategy::Base)
        return self.config == other.config && self.default? == other.default?
      end
    end
  end
end
