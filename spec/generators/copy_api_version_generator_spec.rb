require 'spec_helper'
require 'generator_spec/test_case'

describe Versionist::CopyApiVersionGenerator do
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
      context "api version doesn't exist" do
        before :each do
          ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\nend"}
        end

        after :each do
          if older_than_rails_5?
            ::FileUtils.rm_rf(::File.expand_path("../../tmp/test/integration/#{module_name_for_path(mod)}", __FILE__))
          end
          ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/app/helpers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/#{test_path}/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.rm_rf(::File.expand_path("../../tmp/spec/requests/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = nil
        end

        it "should not raise an error if old version not found config/routes.rb" do
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in app/controllers" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in test path when Test::Unit is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :test_unit
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in test/integration when Test::Unit is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :test_unit
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in spec/controllers when rspec is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :rspec
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in spec/requests when rspec is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :rspec
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in app/presenters" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :rspec
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in test/presenters when Test::Unit is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/#{test_path}/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :test_unit
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version module not found in spec/presenters when rspec is the test framework" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :rspec
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end

        it "should not raise an error if old version not found in public/docs" do
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/presenters/#{module_name_for_path(mod)}", __FILE__))
          Versionist.configuration.configured_test_framework = :rspec
          lambda {
            run_generator [ver, mod, "x", "X", {}]
          }.should_not raise_error
        end
      end

      context "api version exists" do
        before :each do
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/presenters/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/helpers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/helpers/#{module_name_for_path(mod)}", __FILE__))
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/public/docs/#{ver}", __FILE__))
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do\n  end\nend"}
          ::File.open(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}/base_controller.rb", __FILE__), "w") {|f| f.write "class #{mod}::BaseController < ApplicationController\nend"}
          ::File.open(::File.expand_path("../../tmp/app/controllers/#{module_name_for_path(mod)}/foos_controller.rb", __FILE__), "w") {|f| f.write "class #{mod}::FoosController < #{mod}::BaseController\nend"}
          ::File.open(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}/base_presenter.rb", __FILE__), "w") {|f| f.write "class #{mod}::BasePresenter\n\n  def initialize(#{ver})\n    @#{ver} = #{ver}\n  end\n\n  def as_json(options={})\n    # fill me in...\n  end\n\n  def to_xml(options={}, &block)\n    xml = options[:builder] ||= Builder::XmlMarkup.new\n    # fill me in...\n  end\nend"}
          ::File.open(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}/foo_presenter.rb", __FILE__), "w") {|f| f.write "class #{mod}::FooPresenter < #{mod}::BasePresenter\n\n  def initialize(#{ver})\n    @#{ver} = #{ver}\n  end\n\n  def as_json(options={})\n    # fill me in...\n  end\n\n  def to_xml(options={}, &block)\n    xml = options[:builder] ||= Builder::XmlMarkup.new\n    # fill me in...\n  end\nend"}
          ::File.open(::File.expand_path("../../tmp/app/helpers/#{module_name_for_path(mod)}/foos_helper.rb", __FILE__), "w") {|f| f.write "module #{mod}::FoosHelper\n\n  def help\n  end\nend"}
          ::File.open(::File.expand_path("../../tmp/public/docs/#{ver}/style.css", __FILE__), "w") {|f| f.write "body {margin: 0; background-color: #fff; color: #000; font-family: Arial,sans-serif;}\ncontent {margin-left: 200px;}\ncontent h1 {text-align: center;}\noperations {float: left; width: 200px; border-right: 1px solid #ccc;}\noperations h3 {text-align: center;}"}
          ::File.open(::File.expand_path("../../tmp/public/docs/#{ver}/index.html", __FILE__), "w") {|f| f.write "<!DOCTYPE html>\n<html lang=\"en-US\">\n  <head>\n    <title>Documentation for #{ver}</title>\n    <link href=\"#{ver}/style.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">\n  </head>\n  <body>\n    <div id=\"container\">\n      <div id=\"operations\">\n        <h3>API Operations</h3>\n      </div>\n      <div id=\"content\">\n        <h1>Documentation for #{ver}</h1>\n      </div>\n    </div>\n  </body>\n</html>"}
          Versionist.configuration.configured_test_framework = nil
          run_generator [ver, mod, "x", "X"]
        end

        it "should copy correct api_version to config/routes.rb" do
          if RUBY_VERSION =~ /1.9/ && defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"
            assert_file "config/routes.rb"
            expected = <<-CONTENTS
Test::Application.routes.draw do
  api_version(:module => \"X\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-x\") do
  end

  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-#{ver}\") do
  end
end
            CONTENTS

            # Rails 4 removed the trailing newline from the 'route' generator
            # https://github.com/rails/rails/commit/7cdb12286639b38db2eb1e9fd0c8b2e6bc3b39dc
            if Rails::VERSION::MAJOR < 4
              assert_file "config/routes.rb", expected.chop
            elsif Rails::VERSION::MAJOR == 4
              assert_file "config/routes.rb", expected.gsub(/^$\n/, '').chop
            end
          end
        end

        it "should copy old controllers to new controllers" do
          expected_base_controller = <<-BASE
class X::BaseController < ApplicationController
end
          BASE

          expected_foos_controller = <<-FOOS
class X::FoosController < X::BaseController
end
          FOOS

          assert_file "app/controllers/#{module_name_for_path("X")}/base_controller.rb", expected_base_controller.chop
          assert_file "app/controllers/#{module_name_for_path("X")}/foos_controller.rb", expected_foos_controller.chop
        end

        it "should copy old presenters to new presenters" do
          expected_base_presenter = <<-BASE
class X::BasePresenter

  def initialize(#{ver})
    @#{ver} = #{ver}
  end

  def as_json(options={})
    # fill me in...
  end

  def to_xml(options={}, &block)
    xml = options[:builder] ||= Builder::XmlMarkup.new
    # fill me in...
  end
end
          BASE

          expected_foo_presenter = <<-FOOS
class X::FooPresenter < X::BasePresenter

  def initialize(#{ver})
    @#{ver} = #{ver}
  end

  def as_json(options={})
    # fill me in...
  end

  def to_xml(options={}, &block)
    xml = options[:builder] ||= Builder::XmlMarkup.new
    # fill me in...
  end
end
          FOOS

          assert_file "app/presenters/#{module_name_for_path("X")}/base_presenter.rb", expected_base_presenter.chop
          assert_file "app/presenters/#{module_name_for_path("X")}/foo_presenter.rb", expected_foo_presenter.chop
        end

        it "should copy old helpers to new helpers" do
          expected_foos_helper = <<-DOC
module X::FoosHelper

  def help
  end
end
          DOC

          assert_file "app/helpers/#{module_name_for_path("X")}/foos_helper.rb", expected_foos_helper.chop
        end

        it "should copy documentation" do
          assert_file "public/docs/x/style.css"
          assert_file "public/docs/x/index.html"
        end

        context "test_framework: test_unit" do
          before :each do
            if older_than_rails_5?
              ::FileUtils.mkdir_p(::File.expand_path("../../tmp/test/integration/#{module_name_for_path(mod)}", __FILE__))
              ::File.open(::File.expand_path("../../tmp/test/integration/#{module_name_for_path(mod)}/base_controller_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::BaseControllerTest < ActionDispatch::IntegrationTest\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
              ::File.open(::File.expand_path("../../tmp/test/integration/#{module_name_for_path(mod)}/foos_controller_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::FoosControllerTest < ActionDispatch::IntegrationTest\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            end
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/#{test_path}/#{module_name_for_path(mod)}", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/test/presenters/#{module_name_for_path(mod)}", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/test/helpers/#{module_name_for_path(mod)}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/#{test_path}/#{module_name_for_path(mod)}/base_controller_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::BaseControllerTest < ActionController::TestCase\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            ::File.open(::File.expand_path("../../tmp/#{test_path}/#{module_name_for_path(mod)}/foos_controller_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::FoosControllerTest < ActionController::TestCase\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            ::File.open(::File.expand_path("../../tmp/test/presenters/#{module_name_for_path(mod)}/base_presenter_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::BasePresenterTest < Test::Unit::TestCase\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            ::File.open(::File.expand_path("../../tmp/test/presenters/#{module_name_for_path(mod)}/foo_presenter_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::FooPresenterTest < Test::Unit::TestCase\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            ::File.open(::File.expand_path("../../tmp/test/helpers/#{module_name_for_path(mod)}/foos_helper_test.rb", __FILE__), "w") {|f| f.write "require 'test_helper'\n\nclass #{mod}::FoosHelperTest < Test::Unit::TestCase\n  # Replace this with your real tests.\n  test \"the truth\" do\n    assert true\n  end\nend"}
            Versionist.configuration.configured_test_framework = :test_unit
            run_generator [ver, mod, "x", "X"]
          end

          it "should copy old controller tests to new controller tests" do
            expected_base_controller_functional_test = <<-BASE
require 'test_helper'

class X::BaseControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            BASE

            if older_than_rails_5?
              expected_base_controller_integration_test = <<-BASE
require 'test_helper'

class X::BaseControllerTest < ActionDispatch::IntegrationTest
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
              BASE
            end

            expected_foos_controller_functional_test = <<-FOOS
require 'test_helper'

class X::FoosControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            FOOS

            if older_than_rails_5?
              expected_foos_controller_integration_test = <<-FOOS
require 'test_helper'

class X::FoosControllerTest < ActionDispatch::IntegrationTest
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
              FOOS
            end


            assert_file "#{test_path}/#{module_name_for_path("X")}/base_controller_test.rb", expected_base_controller_functional_test.chop
            assert_file "#{test_path}/#{module_name_for_path("X")}/foos_controller_test.rb", expected_foos_controller_functional_test.chop
            if older_than_rails_5?
              assert_file "test/integration/#{module_name_for_path("X")}/base_controller_test.rb", expected_base_controller_integration_test.chop
              assert_file "test/integration/#{module_name_for_path("X")}/foos_controller_test.rb", expected_foos_controller_integration_test.chop
            end
          end

          it "should copy old presenter tests to new presenter tests" do
            expected_base_presenter_test = <<-BASE
require 'test_helper'

class X::BasePresenterTest < Test::Unit::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            BASE

            expected_foo_presenter_test = <<-FOOS
require 'test_helper'

class X::FooPresenterTest < Test::Unit::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            FOOS

            assert_file "test/presenters/#{module_name_for_path("X")}/base_presenter_test.rb", expected_base_presenter_test.chop
            assert_file "test/presenters/#{module_name_for_path("X")}/foo_presenter_test.rb", expected_foo_presenter_test.chop
          end

          it "should copy old helper tests to new helper tests" do
            expected_foos_helper_test = <<-DOC
require 'test_helper'

class X::FoosHelperTest < Test::Unit::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
            DOC

            assert_file "test/helpers/#{module_name_for_path("X")}/foos_helper_test.rb", expected_foos_helper_test.chop
          end
        end

        context "test_framework: rspec" do
          before :each do
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/requests/#{module_name_for_path(mod)}", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/presenters/#{module_name_for_path(mod)}", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec/helpers/#{module_name_for_path(mod)}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}/base_controller_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::BaseController do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/controllers/#{module_name_for_path(mod)}/foos_controller_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::FoosController do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/requests/#{module_name_for_path(mod)}/base_controller_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::BaseController do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/requests/#{module_name_for_path(mod)}/foos_controller_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::FoosController do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/presenters/#{module_name_for_path(mod)}/base_presenter_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::BasePresenter do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/presenters/#{module_name_for_path(mod)}/foo_presenter_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::FooPresenter do\n\nend"}
            ::File.open(::File.expand_path("../../tmp/spec/helpers/#{module_name_for_path(mod)}/foos_helper_spec.rb", __FILE__), "w") {|f| f.write "require 'spec_helper'\n\ndescribe #{mod}::FoosHelper do\n\nend"}
            Versionist.configuration.configured_test_framework = :rspec
            run_generator [ver, mod, "x", "X"]
          end

          it "should copy old controller specs to new controller specs" do
            expected_base_controller_spec = <<-BASE
require 'spec_helper'

describe X::BaseController do

end
            BASE

            expected_foos_controller_spec = <<-FOOS
require 'spec_helper'

describe X::FoosController do

end
            FOOS

            assert_file "spec/controllers/#{module_name_for_path("X")}/base_controller_spec.rb", expected_base_controller_spec.chop
            assert_file "spec/controllers/#{module_name_for_path("X")}/foos_controller_spec.rb", expected_foos_controller_spec.chop
            assert_file "spec/requests/#{module_name_for_path("X")}/base_controller_spec.rb", expected_base_controller_spec.chop
            assert_file "spec/requests/#{module_name_for_path("X")}/foos_controller_spec.rb", expected_foos_controller_spec.chop
          end

          it "should copy old presenter specs to new presenter specs" do
            expected_base_presenter_spec = <<-BASE
require 'spec_helper'

describe X::BasePresenter do

end
            BASE

            expected_foo_presenter_spec = <<-FOOS
require 'spec_helper'

describe X::FooPresenter do

end
            FOOS

            assert_file "spec/presenters/#{module_name_for_path("X")}/base_presenter_spec.rb", expected_base_presenter_spec.chop
            assert_file "spec/presenters/#{module_name_for_path("X")}/foo_presenter_spec.rb", expected_foo_presenter_spec.chop
          end

          it "should copy old helper specs to new helper specs" do
            expected_foos_helper_spec = <<-DOC
require 'spec_helper'

describe X::FoosHelper do

end
            DOC

            assert_file "spec/helpers/#{module_name_for_path("X")}/foos_helper_spec.rb", expected_foos_helper_spec.chop
          end
        end
      end
    end
  end
end
