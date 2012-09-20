require 'spec_helper'

describe Versionist::VersioningStrategy::Default do
  before :each do
    Versionist.configuration.clear!
  end

  after :each do
    Versionist.configuration.clear!
  end

  it "should set attributes" do
    @default = Versionist::VersioningStrategy::Default.new({:module => "V1", :header => {:name => "Accept", :value => "v1"}})
    @default.module.should == "V1"
    Versionist.configuration.default_version.should_not be_nil
    Versionist.configuration.default_version.should == @default
  end

  it "should raise an error when attempting to set more than one :default version" do
    Versionist.configuration.default_version.should be_nil
    Versionist::VersioningStrategy::Default.new({:module => "V1", :default => true, :path => "foo"})
    Versionist.configuration.default_version.should_not be_nil
    lambda {
      Versionist::VersioningStrategy::Default.new({:module => "V2", :default => true, :path => "bar"})
    }.should raise_error(ArgumentError, /attempt to set more than one default api version/)
  end

  context "==" do
    before :each do
      @header = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=1"}})
      @equal_header = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=1"}})
    end

    it "should return true if passed an equal object" do
      (@header == @equal_header).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Header" do
      (@header == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_header = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=2"}})
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
