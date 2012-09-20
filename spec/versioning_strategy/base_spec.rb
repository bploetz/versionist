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

    @base2 = Versionist::VersioningStrategy::Base.new({"module" => "V1"})
    # symbolize_keys! should be called
    @base2.config.should_not == {"module" => "V1"}
    @base2.config.should == {:module => "V1"}
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

  context "==" do
    before :each do
      @base = Versionist::VersioningStrategy::Base.new({:default => false})
      @equal_base = Versionist::VersioningStrategy::Base.new({:default => false})
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
