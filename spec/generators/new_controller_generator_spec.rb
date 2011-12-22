require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewControllerGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
    ::Dir.mkdir(::File.expand_path("../../tmp/config", __FILE__))
    ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
  end

  context "controller" do
    context "base" do
      before :each do
        run_generator %w(foo v1)
      end

      it "should create a namespaced controller" do
        assert_file "app/controllers/v1/foo_controller.rb", "class V1::FooController < BaseController\nend\n"
      end
    end

    context "special characters in version name" do
      before :each do
        run_generator %w(foo v3.4.2)
      end

      it "should create a namespaced controller" do
        assert_file "app/controllers/v3.4.2/foo_controller.rb", "class V3_4_2::FooController < BaseController\nend\n"
      end
    end
  end

  context "routes" do
    context "new api version" do
      before :each do
        ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
        run_generator %w(foo v1)
      end

      it "should create a scope for the new version and add the resource to routes.rb" do
        assert_file "config/routes.rb"
        assert_file "config/routes.rb", "Test::Application.routes.draw do\n  scope :module => \"v1\" do\n    resources :foo\n  end\nend"
      end
    end

    context "existing api version" do
      before :each do
        ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  scope :module => \"v3\" do\n  end\nend"}
        run_generator %w(foo v3)
      end

      it "should add the new resource to the existing scope in routes.rb" do
        assert_file "config/routes.rb"
        assert_file "config/routes.rb", "Test::Application.routes.draw do\n  scope :module => \"v3\" do\n    resources :foo\n  end\nend"
      end
    end
  end
end
