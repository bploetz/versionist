require 'erb'

module Versionist
  module VersioningStrategy
    # Implements the header versioning strategy. Inspects the Accept header
    # to determine the requested version. Assumes the following format:
    # Accept: application/vnd.<vendor_name>-<version>+<format>
    class Header < Base

      # Creates a new Header VersioningStrategy object.
      # The config hash must contain the following properties:
      # - header the header to inspect
      # - template the template of the header
      def initialize(version, config={})
        super
        raise ArgumentError, "header must be specified for the header versioning_strategy" if !config.has_key?(:header)
        raise ArgumentError, "template must be specified for the header versioning_strategy" if !config.has_key?(:template)
        @erb_template = ERB.new(@config[:template], 0, "%<>")
      end

      def matches?(request)
        b = binding
        version = @version
        # TODO:
        format = "foobar"
        versioned_header_string = @erb_template.result(b)
        passed_header_string = request.headers[@config[:header]]
        return passed_header_string == versioned_header_string
      end
    end
  end
end
