module Versionist
  module VersioningStrategy
    # Implements the path versioning strategy. It expects the following path format:
    # GET /<version>/...
    class Path < Base

      # Creates a new Path VersioningStrategy object. config must contain the following keys:
      # - :path the path prefix containing the version
      def initialize(config)
        raise ArgumentError, "you must specify :path in the configuration Hash" if !config.has_key?(:path)
        super
      end
    end
  end
end
