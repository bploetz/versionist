require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewControllerGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
  end

  context "core logic" do
    before :each do
      run_generator %w(foo v1)
    end

    it "should create a namespaced controller" do
      assert_file "app/controllers/v1/foo_controller.rb", <<-CONTENTS
class V1::FooController < BaseController
end
      CONTENTS
    end
  end

  context "special characters in version name" do
    before :each do
      run_generator %w(foo v3.4.2)
    end

    it "should create a namespaced controller" do
      assert_file "app/controllers/v3.4.2/foo_controller.rb", <<-CONTENTS
class V3_4_2::FooController < BaseController
end
      CONTENTS
    end
  end
end
