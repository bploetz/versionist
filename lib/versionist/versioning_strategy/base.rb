module Versionist
  module VersioningStrategy
    class Base

      HEADER_STRATEGY = "header"
      URL_STRATEGY = "url"

      def initialize(version, config={})
        @version = version
        @config = config
        @config.symbolize_keys!
      end
    end
  end
end
