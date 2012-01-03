require 'spec_helper'

describe Versionist::VersioningStrategy::Base do
  it "should raise an error when config nil" do
    lambda {
      Versionist::VersioningStrategy::Base.new(nil)
    }.should raise_error(ArgumentError, /you must pass a configuration Hash/)
  end

  it "should raise an error when config is not a Hash" do
    lambda {
      Versionist::VersioningStrategy::Base.new(1)
    }.should raise_error(ArgumentError, /you must pass a configuration Hash/)
  end

  it "should add self to Versionist::Configuration.versioning_strategies" do
    Versionist.configuration.versioning_strategies.should be_empty
    Versionist::VersioningStrategy::Base.new({})
    Versionist.configuration.versioning_strategies.should_not be_empty
    Versionist.configuration.versioning_strategies.size.should == 1
  end
end
