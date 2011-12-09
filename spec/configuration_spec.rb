require 'spec_helper'

describe Versionist do
  context ".configure" do
    before :each do
      Versionist.configure do |config|
        config.vendor_name = "mydomain.com"
        config.default_version = "v1"
      end
    end

    it "should configure the vendor_name" do
      Versionist.configuration.vendor_name.should == "mydomain.com"
    end

    it "should configure the default_version" do
      Versionist.configuration.default_version.should == "v1"
    end
  end
end
