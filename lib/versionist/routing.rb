module Versionist
  module Routing
    def api_version(version)
      if Versionist.configuration.versioning_strategy_name == Versionist::VersioningStrategy::Base::HEADER_STRATEGY
        return Versionist::VersioningStrategy::Header.new(version, Versionist.configuration.versioning_config)
      elsif Versionist.configuration.versioning_strategy_name == Versionist::VersioningStrategy::Base::URL_STRATEGY
        return Versionist::VersioningStrategy::Url.new(version, Versionist.configuration.versioning_config)
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Versionist::Routing
