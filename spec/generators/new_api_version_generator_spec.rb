require 'spec_helper'
require 'generator_spec/test_case'

describe Versionist::NewApiVersionGenerator do
  include GeneratorSpec::TestCase
  include Versionist::InflectorFixes

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
    ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers", __FILE__))
    ::Dir.mkdir(::File.expand_path("../../tmp/config", __FILE__))
    ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
  end

  {"v1" => "V1", "v2" => "V2", "v2.1" => "V2_1", "v20120119" => "Api::V20120119"}.each do |ver, mod|
    context "#{ver} => #{mod}" do
      context "verify_options" do
        it "should raise an error if no versioning strategies are specified" do
          lambda {
            run_generator %W(#{ver} #{mod})
          }.should raise_error(RuntimeError, /Must specify at least one versioning strategy option/)
        end

        it "should raise an error if header hash doesn't contain name and value keys" do
          lambda {
            run_generator %W(#{ver} #{mod} --header=name:Accept)
          }.should raise_error(RuntimeError, /Must specify name and value for header versioning strategy/)

          lambda {
            run_generator %W(#{ver} #{mod} --header=value:v1)
          }.should raise_error(RuntimeError, /Must specify name and value for header versioning strategy/)
        end

        it "should not raise an error if header hash has both name and value keys" do
          lambda {
            run_generator %W(#{ver} #{mod} --header=name:Accept value:"application/vnd.mycompany.com; version=2")
          }.should_not raise_error
        end

        it "should raise an error if parameter hash doesn't contain name and value keys" do
          lambda {
            run_generator %W(#{ver} #{mod} --parameter=name:Accept)
          }.should raise_error(RuntimeError, /Must specify name and value for parameter versioning strategy/)

          lambda {
            run_generator %W(#{ver} #{mod} --parameter=value:1)
          }.should raise_error(RuntimeError, /Must specify name and value for parameter versioning strategy/)
        end

        it "should not raise an error if parameter hash has both name and value keys" do
          lambda {
            run_generator %W(#{ver} #{mod} --parameter=name:version value:1)
          }.should_not raise_error
        end

        it "should raise an error if path hash doesn't contain value key" do
          lambda {
            run_generator %W(#{ver} #{mod} --path=foo:bar)
          }.should raise_error(RuntimeError, /Must specify value for path versioning strategy/)
        end

        it "should not raise an error if path hash has value key" do
          lambda {
            run_generator %W(#{ver} #{mod} --path=value:v1)
          }.should_not raise_error
        end
      end

      context "api version exists" do
        before :each do
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => {:name => \"Accept\", :value => \"application/vnd.mycompany.com-v1\"}) do\n  end\nend"}
        end

        after :each do
          ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
        end

        it "should raise an error" do
          lambda {
            run_generator %W(#{ver} #{mod} --header=name:Accept value:"application/vnd.mycompany.com-v1")
          }.should raise_error(RuntimeError, /API version already exists in config\/routes.rb/)
        end
      end

      context "api version doesn't exist" do
        before :each do
          ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
          Versionist.configuration.configured_test_framework = nil
          run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver})
        end

        after :each do
          ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
        end

        it "should add correct api_version to config/routes.rb" do
          assert_file "config/routes.rb"
          expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version(:module => "#{module_name_for_route(mod)}", :header => {:name => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}) do
  end

end
          CONTENTS
          assert_file "config/routes.rb", expected.chop
        end

        it "should create a namespaced controller directory" do
          assert_directory "app/controllers/#{module_name_for_path(mod)}"
        end

        it "should create a namespaced base controller" do
          assert_file "app/controllers/#{module_name_for_path(mod)}/base_controller.rb", <<-CONTENTS
class #{mod}::BaseController < ApplicationController
end
          CONTENTS
        end

        it "should create a namespaced presenters directory" do
          assert_directory "app/presenters/#{module_name_for_path(mod)}"
        end

        it "should create a namespaced base presenter" do
          assert_file "app/presenters/#{module_name_for_path(mod)}/base_presenter.rb", <<-CONTENTS
class #{mod}::BasePresenter
end
          CONTENTS
        end

        it "should create a namespaced helpers directory" do
          assert_directory "app/helpers/#{module_name_for_path(mod)}"
        end

        it "should create a documentation directory" do
          assert_directory "public/docs/#{ver}"
        end

        it "should create a documentation index.html" do
          assert_file "public/docs/#{ver}/index.html", <<-CONTENTS
<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Documentation for #{ver}</title>
    <link href="#{ver}/style.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <div id="container">
      <div id="operations">
        <h3>API Operations</h3>
      </div>
      <div id="content">
        <h1>Documentation for #{ver}</h1>
      </div>
    </div>
  </body>
</html>
          CONTENTS
        end

        it "should create a documentation style.css" do
          assert_file "public/docs/#{ver}/style.css", <<-CONTENTS
body {margin: 0; background-color: #fff; color: #000; font-family: Arial,sans-serif;}
content {margin-left: 200px;}
content h1 {text-align: center;}
operations {float: left; width: 200px; border-right: 1px solid #ccc;}
operations h3 {text-align: center;}
          CONTENTS
        end

        context "multiple versioning strategies" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
            Versionist.configuration.configured_test_framework = nil
            run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver} --parameter=name:version value:#{ver} --path=value:/#{ver})
          end

          after :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          end

          it "should add all versioning strategies to api_version to config/routes.rb" do
            assert_file "config/routes.rb"
            expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version(:module => "#{module_name_for_route(mod)}", :header => {:name => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}, :parameter => {:name => "version", :value => "#{ver}"}, :path => {:value => "/#{ver}"}) do
  end

end
            CONTENTS
            assert_file "config/routes.rb", expected.chop
          end
        end

        context ":defaults hash" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
            Versionist.configuration.configured_test_framework = nil
            run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver} --defaults=format:json)
          end

          after :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          end

          it "should add :defaults hash to api_version to config/routes.rb" do
            assert_file "config/routes.rb"
            expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version(:module => "#{module_name_for_route(mod)}", :header => {:name => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}, :defaults => {:format => "json"}) do
  end

end
            CONTENTS
            assert_file "config/routes.rb", expected.chop
          end
        end

        context ":default" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
            Versionist.configuration.configured_test_framework = nil
            run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver} --default)
          end

          after :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          end

          it "should add :default to api_version to config/routes.rb" do
            assert_file "config/routes.rb"
            expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version(:module => "#{module_name_for_route(mod)}", :header => {:name => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}, :default => true) do
  end

end
            CONTENTS
            assert_file "config/routes.rb", expected.chop
          end
        end

        context "test_framework: test_unit" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            Versionist.configuration.configured_test_framework = :test_unit
            run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver})
          end

          it "should create a namespaced test/functional directory" do
            assert_directory "test/functional/#{module_name_for_path(mod)}"
          end

          it "should create a namespaced base controller functional test" do
            assert_file "test/functional/#{module_name_for_path(mod)}/base_controller_test.rb", <<-CONTENTS
require 'test_helper'

class #{mod}::BaseControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            CONTENTS
          end

          it "should create a namespaced base controller integration test" do
            assert_file "test/integration/#{module_name_for_path(mod)}/base_controller_test.rb", <<-CONTENTS
require 'test_helper'

class #{mod}::BaseControllerTest < ActionDispatch::IntegrationTest
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            CONTENTS
          end

          it "should create a namespaced test/presenters directory" do
            assert_directory "test/presenters/#{module_name_for_path(mod)}"
          end

          it "should create a namespaced base presenter test" do
            assert_file "test/presenters/#{module_name_for_path(mod)}/base_presenter_test.rb", <<-CONTENTS
require 'test_helper'

class #{mod}::BasePresenterTest < Test::Unit::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            CONTENTS
          end

          it "should create a namespaced test/helpers directory" do
            assert_directory "test/helpers/#{module_name_for_path(mod)}"
          end
        end

        context "test_framework: rspec" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            Versionist.configuration.configured_test_framework = :rspec
            run_generator %W(#{ver} #{mod} --header=name:Accept value:application/vnd.mycompany.com-#{ver})
          end

          it "should create a namespaced spec/controllers directory" do
            assert_directory "spec/controllers/#{module_name_for_path(mod)}"
          end

          it "should create a namespaced base controller spec" do
            assert_file "spec/controllers/#{module_name_for_path(mod)}/base_controller_spec.rb", <<-CONTENTS
require 'spec_helper'

describe #{mod}::BaseController do

end
            CONTENTS
          end

          it "should create a namespaced base request spec" do
            assert_file "spec/requests/#{module_name_for_path(mod)}/base_controller_spec.rb", <<-CONTENTS
require 'spec_helper'

describe #{mod}::BaseController do

end
            CONTENTS
          end

          it "should create a namespaced spec/presenters directory" do
            assert_directory "spec/presenters/#{module_name_for_path(mod)}"
          end

          it "should create a namespaced base presenter spec" do
            assert_file "spec/presenters/#{module_name_for_path(mod)}/base_presenter_spec.rb", <<-CONTENTS
require 'spec_helper'

describe #{mod}::BasePresenter do

end
            CONTENTS
          end

          it "should create a namespaced spec/helpers directory" do
            assert_directory "spec/helpers/#{module_name_for_path(mod)}"
          end
        end
      end
    end
  end
end
