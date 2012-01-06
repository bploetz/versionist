module Versionist
  module VersioningStrategy
    # Implements the parameter versioning strategy.
    class Parameter < Base

      # Creates a new Parameter VersioningStrategy object. config must contain the following keys:
      # - :parameter the parameter to inspect
      # - :value the value of the parameter specifying the version
      def initialize(config)
        raise ArgumentError, "you must specify :parameter in the configuration Hash" if !config.has_key?(:parameter)
        raise ArgumentError, "you must specify :value in the configuration Hash" if !config.has_key?(:value)
        super
      end

      def matches?(request)
        return !request.params[config[:parameter]].nil? && request.params[config[:parameter]] == config[:value]
      end
    end
  end
end
