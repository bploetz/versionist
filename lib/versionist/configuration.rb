require 'active_model'

module Versionist
  class Configuration
    include ActiveModel::Validations
    include ActiveModel::Validations::HelperMethods

    attr_accessor :versioning_scheme
    validates_inclusion_of :versioning_scheme, :in => %W( header url )

    attr_accessor :vendor_name
    attr_accessor :default_version
  end
end
