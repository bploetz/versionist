require 'spec_helper'

describe Versionist do
  context ".configure" do
    before :each do
      Versionist.configure do |config|
        config.versioning_scheme = "header"
        config.vendor_name = "mydomain.com"
        config.default_version = "v1"
      end
    end

    it "should configure the versioning_scheme" do
      Versionist.configuration.versioning_scheme.should == "header"
    end

    it "should configure the vendor_name" do
      Versionist.configuration.vendor_name.should == "mydomain.com"
    end

    it "should configure the default_version" do
      Versionist.configuration.default_version.should == "v1"
    end

    it "should validate versioning_scheme" do
      Versionist.configure do |config|
        config.versioning_scheme = "bogus"
      end
      Versionist.configuration.valid?.should == false

      Versionist.configure do |config|
        config.versioning_scheme = "header"
      end
      Versionist.configuration.valid?.should == true

      Versionist.configure do |config|
        config.versioning_scheme = "url"
      end
      Versionist.configuration.valid?.should == true
    end
  end
end
