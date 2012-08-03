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

  context "==" do
    before :each do
      @parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => "version", :value => "1"})
      @equal_parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => "version", :value => "1"})
    end

    it "should return true if passed an equal object" do
      (@parameter == @equal_parameter).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Parameter" do
      (@parameter == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => "ver", :value => "1"})
      (@parameter == @unequal_parameter).should == false
    end

    it "should find equal versioning strategies via Array.include?" do
      @array = Array.new
      @array << @parameter
      @array.include?(@parameter).should == true
      @array.include?(@equal_parameter).should == true
    end
  end
end
