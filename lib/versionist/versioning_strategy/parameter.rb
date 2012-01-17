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
        Versionist.configuration.parameter_versions << config[:value]
      end

      def matches?(request)
        parameter_string = request.params[config[:parameter]].to_s
        return ((!parameter_string.blank? && parameter_string == config[:value]) ||
                (self.default? && (Versionist.configuration.parameter_versions.none? {|v| parameter_string.include?(v)})))
      end
    end
  end
end
