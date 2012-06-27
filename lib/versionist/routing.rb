module Versionist
  module Routing
    # Allows you to constrain routes to specific versions of your api using versioning strategies.
    # Supported formats:
    # api_version(:module => "v1", :header => "Accept", :value => "application/vnd.mycompany.com-v1")
    # api_version(:module => "v2__3__4", :path => "/v2.3.4")
    # api_version(:module => "v20120317", :parameter => "version", :value => "v20120317")
    #
    # Specifying default version:
    # api_version(:module => "v3__0__0", :header => "API-VERSION", :value => "v3.0.0", :default => true)
    def api_version(config, &block)
      raise ArgumentError, "you must pass a configuration Hash to api_version" if config.nil? || !config.is_a?(Hash)
      raise ArgumentError, "you must specify :module in configuration Hash passed to api_version" if !config.has_key?(:module)
      raise ArgumentError, "you must specify :header, :path, or :parameter in configuration Hash passed to api_version" if !config.has_key?(:header) && !config.has_key?(:path) && !config.has_key?(:parameter)
      raise ArgumentError, ":defaults must be a Hash" if config.has_key?(:defaults) && !config[:defaults].is_a?(Hash)
      if config.has_key?(:header)
        return configure_header(config, &block)
      elsif config.has_key?(:path)
        return configure_path(config, &block)
      elsif config.has_key?(:parameter)
        configure_parameter(config, &block)
      end
    end


    private

    def configure_header(config, &block)
      header = Versionist::VersioningStrategy::Header.new(config)
      route_hash = {:module => config[:module], :constraints => header}
      route_hash.merge!({:defaults => config[:defaults]}) if config.has_key?(:defaults)
      scope(route_hash, &block)
    end

    def configure_path(config, &block)
      path = Versionist::VersioningStrategy::Path.new(config)
      # Use the :as option and strip out non-word characters from the path to avoid this:
      # https://github.com/rails/rails/issues/3224
      route_hash = {:module => config[:module], :as => config[:path].gsub(/\W/, '_')}
      route_hash.merge!({:defaults => config[:defaults]}) if config.has_key?(:defaults)
      namespace(config[:path], route_hash, &block)
      if path.default?
        scope(route_hash, &block)
      end
    end

    def configure_parameter(config, &block)
      parameter = Versionist::VersioningStrategy::Parameter.new(config)
      route_hash = {:module => config[:module], :constraints => parameter}
      route_hash.merge!({:defaults => config[:defaults]}) if config.has_key?(:defaults)
      scope(route_hash, &block)
    end
  end
end

# Hook to clear versionist cached data when routes are reloaded
module Rails
  class Application #:nodoc:
    def reload_routes_with_versionist!
      Versionist.configuration.clear!
      reload_routes_without_versionist!
    end
    alias_method_chain :reload_routes!, :versionist
  end
end
