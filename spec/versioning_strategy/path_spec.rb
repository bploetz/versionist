require 'spec_helper'

describe Versionist::VersioningStrategy::Path do
  it "should raise an ArgumentError if :path is not specified" do
    lambda {
      Versionist::VersioningStrategy::Path.new({})
    }.should raise_error(ArgumentError, /you must specify :path in the configuration Hash/)
  end

  context "==" do
    before :each do
      @path = Versionist::VersioningStrategy::Path.new({:path => "/v1"})
      @equal_path = Versionist::VersioningStrategy::Path.new({:path => "/v1"})
    end

    it "should return true if passed an equal object" do
      (@path == @equal_path).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Path" do
      (@path == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_path = Versionist::VersioningStrategy::Path.new({:path => "v2"})
      (@path == @unequal_path).should == false
    end

    it "should find equal versioning strategies via Array.include?" do
      @array = Array.new
      @array << @path
      @array.include?(@path).should == true
      @array.include?(@equal_path).should == true
    end
  end
end
