module Versionist
  module VersioningStrategy
    # Implements the header versioning strategy.
    class Header < Base

      # Creates a new Header VersioningStrategy object. config must contain the following keys:
      # - :header the header to inspect
      # - :value the value of the header specifying the version
      def initialize(config)
        super
        raise ArgumentError, "you must specify :header in the configuration Hash" if !config.has_key?(:header)
        raise ArgumentError, "you must specify :value in the configuration Hash" if !config.has_key?(:value)
        Versionist.configuration.header_versions << config[:value]
      end

      def matches?(request)
        header_string = request.headers[config[:header]].to_s
        return true if matches_using_custom_header?(header_string)
        return true if matches_using_accept?(header_string)
        return true if self.default? && (Versionist.configuration.header_versions.none? {|v| header_string.include?(v)})
        false
      end

      def matches_using_accept?(string)
        string.include?(config[:value])
      end

      def matches_using_custom_header?(string)
        string.eql?(config[:value])
      end

      def ==(other)
        super
        return false if !other.is_a?(Versionist::VersioningStrategy::Header)
        return config[:header] == other.config[:header] && self.config[:value] == other.config[:value]
      end
    end
  end
end
