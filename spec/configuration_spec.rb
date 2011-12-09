require 'spec_helper'

describe Versionist do
  context ".configure" do
    before :each do
      Versionist.configure do |config|
        config.vendor_name = "mydomain.com"
      end
    end

    it "should configure the vendor_name" do
      Versionist.configuration.vendor_name.should == "mydomain.com"
    end
  end
end
