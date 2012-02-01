require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewControllerGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
    ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers", __FILE__))
    ::Dir.mkdir(::File.expand_path("../../tmp/config", __FILE__))
    ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
  end

  context "controller" do
    context "api version doesn't exist" do
      it "should raise an error if the api version doesn't exist yet" do
        lambda {
          run_generator %w(v1 V1)
        }.should raise_error(RuntimeError, /API module namespace V1 doesn't exist. Please run \'rails generate versionist:new_api_version\' generator first/)
      end
    end

    context "api version exists" do
      {"foo" => "V1", "bar" => "V2", "foos" => "V2_1", "bazs" => "Api::V3"}.each do |name, mod|
        context "#{name} => #{mod}" do
          before :each do
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{mod.underscore}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version({:module => \"#{mod}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\"}) do\n  end\nend"}
            run_generator [name, mod]
          end

          it "should create a namespaced controller" do
            assert_directory "app/controllers/#{mod.underscore}"
            assert_file "app/controllers/#{mod.underscore}/#{name.underscore}_controller.rb", "class #{mod}::#{name.camelize}Controller < BaseController\nend\n"
          end
        end
      end
    end
  end

  context "routes" do
    context "api version doesn't exist in config/routes.rb" do
      before :each do
        ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/v1", __FILE__))
        ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
      end

      it "should raise an error" do
        lambda {
          run_generator %w(v1 V1)
        }.should raise_error(RuntimeError, /API version doesn't exist in config\/routes.rb. Please run \'rails generate versionist:new_api_version\' generator first/)
      end
    end

    context "api version duplicated in config/routes.rb" do
      before :each do
        ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/v1", __FILE__))
        ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version({:module => \"V1\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\"}) do\n  end\n\n  api_version({:module => \"V1\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\"}) do\n  end\nend"}
      end

      it "should raise an error" do
        lambda {
          run_generator %w(v1 V1)
        }.should raise_error(RuntimeError, /API version is duplicated in config\/routes.rb/)
      end
    end

    context "api version exists" do
      {"foo" => "V1", "bar" => "V2", "foos" => "V2_1", "bazs" => "Api::V3"}.each do |name, mod|
        context "#{name} => #{mod}" do
          before :each do
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{mod.underscore}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version({:module => \"#{mod}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\"}) do\n  end\nend"}
            run_generator [name, mod]
          end

          it "should add the new resource to the existing scope in routes.rb" do
            assert_file "config/routes.rb"
            expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version({:module => "#{mod}", :header => "Accept", :value => "application/vnd.mycompany.com-v1"}) do
    resources :#{name}
  end
end
            CONTENTS
            assert_file "config/routes.rb", expected.chop
          end
        end
      end
    end
  end
end
