module Versionist
  module VersioningStrategy
    extend ActiveSupport::Autoload

    autoload :Base, 'versionist/versioning_strategy/base'
    autoload :Header, 'versionist/versioning_strategy/header'
    autoload :Path, 'versionist/versioning_strategy/path'
    autoload :Parameter, 'versionist/versioning_strategy/parameter'
  end
end
