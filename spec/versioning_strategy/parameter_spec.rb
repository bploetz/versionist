require 'spec_helper'

describe Versionist::VersioningStrategy::Parameter do
  it "should raise an ArgumentError if :parameter is not specified" do
    lambda {
      Versionist::VersioningStrategy::Parameter.new({})
    }.should raise_error(ArgumentError, /you must specify :parameter in the configuration Hash/)
  end

  it "should raise an ArgumentError if :value is not specified" do
    lambda {
      Versionist::VersioningStrategy::Parameter.new({:parameter => "version"})
    }.should raise_error(ArgumentError, /you must specify :value in the configuration Hash/)
  end
end
