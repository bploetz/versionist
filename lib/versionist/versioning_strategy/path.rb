module Versionist
  module VersioningStrategy
    # Implements the path versioning strategy. It expects the following path format:
    # GET /<version>/...
    class Path < Base

      # Creates a new Path VersioningStrategy object. config must contain the following keys:
      # - :path the path prefix containing the version
      def initialize(config)
        super
        raise ArgumentError, "you must specify :path in the configuration Hash" if !config.has_key?(:path)
      end

      def ==(other)
        super
        return false if !other.is_a?(Versionist::VersioningStrategy::Path)
        return config[:path] == other.config[:path]
      end
    end
  end
end
