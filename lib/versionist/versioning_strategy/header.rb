module Versionist
  module VersioningStrategy
    # Implements the header versioning strategy.
    class Header < Base

      # Creates a new Header VersioningStrategy object. config must contain the following keys:
      # - :header the header hash to inspect
      def initialize(config)
        super
        raise ArgumentError, "you must specify :name in the :header configuration Hash" if !config[:header].has_key?(:name)
        raise ArgumentError, "you must specify :value in the :header configuration Hash" if !config[:header].has_key?(:value)
        Versionist.configuration.header_versions << self if !Versionist.configuration.header_versions.include?(self)
      end

      def matches?(request)
        header_string = request.headers[config[:header][:name]].to_s
        return !header_string.blank? && header_string.include?(config[:header][:value])
      end

      def ==(other)
        super
        return false if !other.is_a?(Versionist::VersioningStrategy::Header)
        return config[:header][:name] == other.config[:header][:name] && self.config[:header][:value] == other.config[:header][:value]
      end
    end
  end
end
