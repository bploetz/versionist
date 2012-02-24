require 'spec_helper'

describe Versionist::InflectorFixes do
  before :each do
    @object = Object.new
    @object.extend(Versionist::InflectorFixes)
  end

  context "#module_name_for_route" do
    it "should transform" do
      @object.module_name_for_route("V2_1_3").should == "V2__1__3"
    end
  end

  context "#module_name_for_path" do
    it "should transform" do
      @object.module_name_for_path("V2_1_3").should == "v2_1_3"
    end
  end
end
