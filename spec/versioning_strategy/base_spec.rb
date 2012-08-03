require 'spec_helper'

describe Versionist::VersioningStrategy::Base do
  after :each do
    Versionist.configuration.clear!
  end
  
  it "should raise an error when config nil" do
    lambda {
      Versionist::VersioningStrategy::Base.new(nil)
    }.should raise_error(ArgumentError, /you must pass a configuration Hash/)
  end

  it "should raise an error when config is not a Hash" do
    lambda {
      Versionist::VersioningStrategy::Base.new(1)
    }.should raise_error(ArgumentError, /you must pass a configuration Hash/)
  end

  it "should set attributes" do
    @base = Versionist::VersioningStrategy::Base.new({})
    @base.config.should == {}
    @base.default?.should == false

    @base2 = Versionist::VersioningStrategy::Base.new({"default" => true})
    @base2.default?.should == true
  end

  it "should call symbolize_keys" do
    @base2 = Versionist::VersioningStrategy::Base.new({"foo" => true})
    @base2.config.should_not == {"foo" => true}
    @base2.config.should == {:foo => true}
  end

  it "should add self to Versionist::Configuration.versioning_strategies" do
    Versionist.configuration.versioning_strategies.should be_empty
    Versionist::VersioningStrategy::Base.new({})
    Versionist.configuration.versioning_strategies.should_not be_empty
    Versionist.configuration.versioning_strategies.size.should == 1
  end

  it "should not add self to Versionist::Configuration.versioning_strategies more than once" do
    Versionist.configuration.versioning_strategies.should be_empty
    Versionist::VersioningStrategy::Base.new({})
    Versionist.configuration.versioning_strategies.should_not be_empty
    Versionist.configuration.versioning_strategies.size.should == 1
    Versionist::VersioningStrategy::Base.new({})
    Versionist.configuration.versioning_strategies.should_not be_empty
    Versionist.configuration.versioning_strategies.size.should == 1
  end

  it "should set self as Versionist::Configuration.default_version if config contains :default" do
    Versionist.configuration.default_version.should be_nil
    Versionist::VersioningStrategy::Base.new({:default => true, :path => "foo"})
    Versionist.configuration.default_version.should_not be_nil
  end

  it "should raise an error when attempting to set more than one :default version" do
    Versionist.configuration.default_version.should be_nil
    Versionist::VersioningStrategy::Base.new({:default => true, :path => "foo"})
    Versionist.configuration.default_version.should_not be_nil
    lambda {
      Versionist::VersioningStrategy::Base.new({:default => true, :path => "bar"})
    }.should raise_error(ArgumentError, /attempt to set more than one default api version/)
  end

  context "==" do
    before :each do
      @base = Versionist::VersioningStrategy::Base.new({:path => 'V1'})
      @equal_base = Versionist::VersioningStrategy::Base.new({:path => 'V1'})
    end

    it "should return true if passed an equal object" do
      (@base == @equal_base).should == true
    end

    it "should return false if passed nil" do
      (@base == nil).should == false
    end

    it "should return false if passed an object that's not a Versionist::VersioningStrategy::Base" do
      (@base == Array.new).should == false
    end

    it "should return false if passed an object that's not equal" do
      @unequal_base = Versionist::VersioningStrategy::Base.new({})
      (@base == @unequal_base).should == false
    end

    it "should find equal versioning strategies via Array.include?" do
      @array = Array.new
      @array << @base
      @array.include?(@base).should == true
      @array.include?(@equal_base).should == true
    end
  end
end
