module Versionist
  module VersioningStrategy
    # Implements the header versioning strategy.
    class Header < Base

      # Creates a new Header VersioningStrategy object. config must contain the following keys:
      # - :header the header to inspect
      # - :value the value of the header specifying the version
      def initialize(config)
        raise ArgumentError, "you must specify :header in the configuration Hash" if !config.has_key?(:header)
        raise ArgumentError, "you must specify :value in the configuration Hash" if !config.has_key?(:value)
        super
      end

      def matches?(request)
        return !request.headers[config[:header]].nil? && request.headers[config[:header]].include?(config[:value])
      end
    end
  end
end
