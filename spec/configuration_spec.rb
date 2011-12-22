require 'spec_helper'

describe Versionist do
  context ".configure" do
    before :each do
      Versionist.configure do |config|
        config.versioning_strategy = "header", {:vendor_name => "mydomain.com"}
        config.default_version = "v1"
      end
    end

    it "should configure the versioning_strategy" do
      Versionist.configuration.versioning_strategy_name.should == "header"
    end

    it "should configure the vendor_name" do
      Versionist.configuration.versioning_config[:vendor_name].should == "mydomain.com"
    end

    it "should configure the default_version" do
      Versionist.configuration.default_version.should == "v1"
    end

    it "should validate versioning_strategy" do
      Versionist.configure do |config|
        config.versioning_strategy = "bogus"
      end
      Versionist.configuration.valid?.should == false

      Versionist.configure do |config|
        config.versioning_strategy = "bogus", {:vendor_name => "foo"}
      end
      Versionist.configuration.valid?.should == false

      Versionist.configure do |config|
        config.versioning_strategy = "header"
      end
      Versionist.configuration.valid?.should == true

      Versionist.configure do |config|
        config.versioning_strategy = "url"
      end
      Versionist.configuration.valid?.should == true
    end
  end
end
