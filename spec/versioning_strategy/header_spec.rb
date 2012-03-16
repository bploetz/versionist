require 'spec_helper'

describe Versionist::VersioningStrategy::Header do
  before :each do
    Versionist.configuration.clear!
  end

  after :each do
    Versionist.configuration.clear!
  end

  it "should raise an ArgumentError if :header is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new({:foo => :bar})
    }.should raise_error(ArgumentError, /you must specify :header in the configuration Hash/)
  end

  it "should raise an ArgumentError if :value is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new({:header => "foo"})
    }.should raise_error(ArgumentError, /you must specify :value in the configuration Hash/)
  end

  it "should add the version to Versionist::Configuration.header_versions" do
    Versionist.configuration.header_versions.should be_empty
    Versionist::VersioningStrategy::Header.new({:header => "foo", :value => "v3"})
    Versionist.configuration.header_versions.include?("v3").should be_true
  end
end
