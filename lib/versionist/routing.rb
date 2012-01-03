module Versionist
  module Routing
    # Allows you to constrain routes to specific versions of your api using versioning strategies.
    # Supported formats:
    # api_version(:header => "Accept", :value => "application/vnd.mycompany.com-v1")
    # api_version(:path => "/v2.3.4/")
    # api_version(:parameter => "version", :value => "v20120317")
    #
    # Specifying default version:
    # api_version(:header => "X-MY-HEADER", :value => "v3.0.0", :default => true)
    def api_version(config)
      raise ArgumentError, "you must pass a configuration Hash to api_version" if config.nil? || !config.is_a?(Hash)
      raise ArgumentError, "you must specify :header, :path, or :parameter in configuration Hash passed to api_version" if !config.has_key?(:header) && !config.has_key?(:path) && !config.has_key?(:parameter)
      if config.has_key?(:header)
        return configure_header(config)
      elsif config.has_key?(:path)
        configure_path(config)
      elsif config.has_key?(:parameter)
        configure_parameter(config)
      end
    end


    private

    def configure_header(config)
      return Versionist::VersioningStrategy::Header.new(config)
    end

    def configure_path(config)
      
    end

    def configure_parameter(config)
      raise ArgumentError, "you must specify :value in the configuration Hash to api_version" if !config.has_key?(:value)
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Versionist::Routing
