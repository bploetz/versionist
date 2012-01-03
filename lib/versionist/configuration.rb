module Versionist
  class Configuration
    attr_accessor :versioning_strategies

    def initialize
      @versioning_strategies ||= Array.new
    end
  end
end
