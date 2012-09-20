require 'spec_helper'

describe Versionist::VersioningStrategy::Header do
  before :each do
    Versionist.configuration.clear!
  end

  after :each do
    Versionist.configuration.clear!
  end

  it "should raise an ArgumentError if :name is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new({:header => {:foo => "foo"}})
    }.should raise_error(ArgumentError, /you must specify :name in the :header configuration Hash/)
  end
 
  it "should raise an ArgumentError if :value is not specified" do
    lambda {
      Versionist::VersioningStrategy::Header.new({:header => {:name => "foo"}})
    }.should raise_error(ArgumentError, /you must specify :value in the :header configuration Hash/)
  end

  it "should add the version to Versionist::Configuration.header_versions" do
    Versionist.configuration.header_versions.should be_empty
    header_version = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com-v2"}})
    Versionist.configuration.header_versions.include?(header_version).should be_true
  end

  it "should not add self to Versionist::Configuration.header_versions more than once" do
    Versionist.configuration.header_versions.should be_empty
    header_version = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com-v2"}})
    Versionist.configuration.header_versions.should_not be_empty
    Versionist.configuration.header_versions.size.should == 1

    header_version2 = Versionist::VersioningStrategy::Header.new({:header => {:name => "Accept", :value => "application/vnd.mycompany.com-v2"}})
    Versionist.configuration.header_versions.should_not be_empty
    Versionist.configuration.header_versions.size.should == 1
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
