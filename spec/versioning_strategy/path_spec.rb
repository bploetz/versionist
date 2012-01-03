require 'spec_helper'

describe Versionist::VersioningStrategy::Path do
  it "should raise an ArgumentError if :path is not specified" do
    lambda {
      Versionist::VersioningStrategy::Path.new({})
    }.should raise_error(ArgumentError, /you must specify :path in the configuration Hash/)
  end
end
