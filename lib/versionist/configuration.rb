require 'active_model/validations'

module Versionist
  class Configuration
    include ActiveModel::Validations
    include ActiveModel::Validations::HelperMethods

    attr_accessor :versioning_strategy_name
    validates_inclusion_of :versioning_strategy_name, :in => %W( header url )
    attr_accessor :versioning_config
    attr_accessor :default_version

    def versioning_strategy=(args)
      if args.is_a?(Array)
        name = args[0]
        raise ArgumentError, "First argument to versioning_strategy= must be a string specifying the versioning_strategy name" if !name.is_a?(String)
        @versioning_strategy_name = name
        if args.length > 1
          config = args[1]
          raise ArgumentError, "Second argument to versioning_strategy= must be a hash specifying the versioning_strategy config" if !config.is_a?(Hash)
          @versioning_config = config
        end
      else
        name = args
        raise ArgumentError, "First argument to versioning_strategy= must be a string specifying the versioning_strategy name" if !name.is_a?(String)
        @versioning_strategy_name = name
      end
    end
  end
end
