require 'spec_helper'

describe Versionist::VersioningStrategy::Parameter do
  before :each do
    Versionist.configuration.clear!
  end

  after :each do
    Versionist.configuration.clear!
  end

  it "should raise an ArgumentError if :name is not specified" do
    lambda {
      Versionist::VersioningStrategy::Parameter.new({:parameter => {:value => "v1"}})
    }.should raise_error(ArgumentError, /you must specify :name in the :parameter configuration Hash/)
  end

  it "should raise an ArgumentError if :value is not specified" do
    lambda {
      Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version"}})
    }.should raise_error(ArgumentError, /you must specify :value in the :parameter configuration Hash/)
  end

  it "should add the version to Versionist::Configuration.parameter_versions" do
    Versionist.configuration.parameter_versions.should be_empty
    parmeter_version = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version", :value => "3"}})
    Versionist.configuration.parameter_versions.include?(parmeter_version).should == true
  end

  it "should not add self to Versionist::Configuration.parameter_versions more than once" do
    Versionist.configuration.parameter_versions.should be_empty
    parameter_version = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version", :value => "v2"}})
    Versionist.configuration.parameter_versions.should_not be_empty
    Versionist.configuration.parameter_versions.size.should == 1

    parameter_version2 = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version", :value => "v2"}})
    Versionist.configuration.parameter_versions.should_not be_empty
    Versionist.configuration.parameter_versions.size.should == 1
  end

  context "==" do
    before :each do
      @parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version", :value => "1"}})
      @equal_parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "version", :value => "1"}})
    end

    it "should return true if passed an equal object" do
      (@parameter == @equal_parameter).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Parameter" do
      (@parameter == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_parameter = Versionist::VersioningStrategy::Parameter.new({:parameter => {:name => "ver", :value => "1"}})
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
