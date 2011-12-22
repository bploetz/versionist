module Versionist
  module VersioningStrategy
    # Implements the URL versioning strategy. It expects the following path format:
    # GET /<version>/...
    class Url < Base

      # Creates a new Url VersioningStrategy object.
      def initialize(version, config={})
        super
      end

      def matches?(request)
        
      end
    end
  end
end