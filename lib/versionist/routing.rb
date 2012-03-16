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
      scope({:module => config[:module], :constraints => header}, &block)
    end

    def configure_path(config, &block)
      path = Versionist::VersioningStrategy::Path.new(config)
      # Use the :as option and strip out non-word characters from the path to avoid this:
      # https://github.com/rails/rails/issues/3224
      namespace(config[:path], {:module => config[:module], :as => config[:path].gsub(/\W/, '_')}, &block)
      if path.default?
        scope({:module => config[:module], :as => config[:path].gsub(/\W/, '_')}, &block)
      end
    end

    def configure_parameter(config, &block)
      parameter = Versionist::VersioningStrategy::Parameter.new(config)
      scope({:module => config[:module], :constraints => parameter}, &block)
    end
  end
end

# Hook to clear versionist cached data when routes are reloaded
module Rails
  class Application #:nodoc:
    class RoutesReloader #:nodoc:
      def reload_with_versionist!
        Versionist.configuration.clear!
        reload_without_versionist!
      end
      alias_method_chain :reload!, :versionist
    end
  end
end
