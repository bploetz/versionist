require 'spec_helper'

describe Versionist::VersioningStrategy::Header do
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
end
