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

  context "==" do
    before :each do
      @header = Versionist::VersioningStrategy::Header.new({:header => "Accept", :value => "application/vnd.mycompany.com; version=1"})
      @equal_header = Versionist::VersioningStrategy::Header.new({:header => "Accept", :value => "application/vnd.mycompany.com; version=1"})
    end

    it "should return true if passed an equal object" do
      (@header == @equal_header).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Header" do
      (@header == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_header = Versionist::VersioningStrategy::Header.new({:header => "Accept", :value => "application/vnd.mycompany.com; version=2"})
      (@header == @unequal_header).should == false
    end

    it "should find equal versioning strategies via Array.include?" do
      @array = Array.new
      @array << @header
      @array.include?(@header).should == true
      @array.include?(@equal_header).should == true
    end
  end
end
