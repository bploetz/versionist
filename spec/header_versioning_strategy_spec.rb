require 'spec_helper'

describe Versionist::VersioningStrategy::Header do
  it "should raise an ArgumentError if header is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new("v1")
    }.should raise_error(ArgumentError, /header must be specified for the header versioning_strategy/)
  end

  it "should raise an ArgumentError if template is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new("v1", {:header => "Accept"})
    }.should raise_error(ArgumentError, /template must be specified for the header versioning_strategy/)
  end
end
