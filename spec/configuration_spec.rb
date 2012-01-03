require 'spec_helper'

describe Versionist do
  before :each do
    Versionist.configuration.versioning_strategies.clear
  end

  after :each do
    Versionist.configuration.versioning_strategies.clear
  end

  it "should add versioning strategies" do
    Versionist.configuration.versioning_strategies.should be_empty
    Versionist::VersioningStrategy::Base.new({})
    Versionist.configuration.versioning_strategies.should_not be_nil
    Versionist.configuration.versioning_strategies.size.should == 1
  end
end
