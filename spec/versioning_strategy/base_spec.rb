require 'spec_helper'

describe Versionist::VersioningStrategy::Base do
  after :each do
    Versionist.configuration.versioning_strategies.clear
    Versionist.configuration.default_version = nil
  end
  
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

  it "should set self as Versionist::Configuration.default_version if config contains :default" do
    Versionist.configuration.default_version.should be_nil
    Versionist::VersioningStrategy::Base.new({:default => true, :path => "foo"})
    Versionist.configuration.default_version.should_not be_nil
  end

  it "should raise an error when attempting to set more than one :default version" do
    Versionist.configuration.default_version.should be_nil
    Versionist::VersioningStrategy::Base.new({:default => true, :path => "foo"})
    Versionist.configuration.default_version.should_not be_nil
    lambda {
      Versionist::VersioningStrategy::Base.new({:default => true, :path => "bar"})
    }.should raise_error(ArgumentError, /attempt set more than one default api version/)
  end
end
