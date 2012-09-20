require 'spec_helper'

describe Versionist::VersioningStrategy::Path do
  before :each do
    Versionist.configuration.clear!
  end

  after :each do
    Versionist.configuration.clear!
  end

  it "should raise an ArgumentError if :value is not specified" do
    lambda {
      Versionist::VersioningStrategy::Path.new({:path => {}})
    }.should raise_error(ArgumentError, /you must specify :value in the :path configuration Hash/)
  end

  it "should add the version to Versionist::Configuration.path_versions" do
    Versionist.configuration.path_versions.should be_empty
    path_version = Versionist::VersioningStrategy::Path.new({:path => {:value => "v1"}})
    Versionist.configuration.path_versions.include?(path_version).should be_true
  end

  context "==" do
    before :each do
      @path = Versionist::VersioningStrategy::Path.new({:path => {:value => "/v1"}})
      @equal_path = Versionist::VersioningStrategy::Path.new({:path => {:value => "/v1"}})
    end

    it "should return true if passed an equal object" do
      (@path == @equal_path).should == true
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Path" do
      (@path == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_path = Versionist::VersioningStrategy::Path.new({:path => {:value => "v2"}})
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
