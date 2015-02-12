require 'spec_helper'
require 'generator_spec/test_case'

describe Versionist::NewPresenterGenerator do
  include GeneratorSpec::TestCase
  include Versionist::InflectorFixes

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
    ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters", __FILE__))
    ::Dir.mkdir(::File.expand_path("../../tmp/config", __FILE__))
    ::FileUtils.touch(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
  end

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
          ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
          ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\") do\n  end\nend"}
          Versionist.configuration.configured_test_framework = nil
          run_generator [name, mod]
        end

        it "should create a namespaced presenter" do
          assert_directory "app/presenters/#{module_name_for_path(mod)}"
          assert_file "app/presenters/#{module_name_for_path(mod)}/#{name.underscore}_presenter.rb", <<-CONTENTS
class #{mod}::#{name.camelize}Presenter < #{mod}::BasePresenter

  def initialize(#{name})
    @#{name} = #{name}
  end

  def as_json(options={})
    # fill me in...
  end

  def to_xml(options={}, &block)
    xml = options[:builder] ||= Builder::XmlMarkup.new
    # fill me in...
  end
end
          CONTENTS
        end

        context "test_framework: test_unit" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\") do\n  end\nend"}
            Versionist.configuration.configured_test_framework = :test_unit
            run_generator [name, mod]
          end

          it "should create a namespaced test/presenters directory" do
            assert_directory "test/presenters/#{module_name_for_path(mod)}"
          end

          it "should create a namespaced presenter test" do
            assert_file "test/presenters/#{module_name_for_path(mod)}/#{name.underscore}_presenter_test.rb", <<-CONTENTS
require 'test_helper'

class #{mod}::#{name.camelize}PresenterTest < Test::Unit::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
              CONTENTS
          end
        end

        context "test_framework: rspec" do
          before :each do
            ::FileUtils.rm(::File.expand_path("../../tmp/config/routes.rb", __FILE__))
            ::FileUtils.mkdir_p(::File.expand_path("../../tmp/app/presenters/#{module_name_for_path(mod)}", __FILE__))
            ::File.open(::File.expand_path("../../tmp/config/routes.rb", __FILE__), "w") {|f| f.write "Test::Application.routes.draw do\n  api_version(:module => \"#{module_name_for_route(mod)}\", :header => \"Accept\", :value => \"application/vnd.mycompany.com-v1\") do\n  end\nend"}
            Versionist.configuration.configured_test_framework = :rspec
          end

          context "directories" do
            before :each do
              run_generator [name, mod]
            end

            it "should create a namespaced spec/presenters directory" do
              assert_directory "spec/presenters/#{module_name_for_path(mod)}"
            end
          end

          context "rspec < 3" do
            before :each do
              run_generator [name, mod]
            end

            it "should create a namespaced presenter spec" do
              assert_file "spec/presenters/#{module_name_for_path(mod)}/#{name.underscore}_presenter_spec.rb", <<-CONTENTS
require 'spec_helper'

describe #{mod}::#{name.camelize}Presenter do

end
              CONTENTS
            end
          end

          context "rspec >= 3" do
            before :each do
              ::FileUtils.mkdir_p(::File.expand_path("../../tmp/spec", __FILE__))
              ::FileUtils.touch(::File.expand_path("../../tmp/spec/rails_helper.rb", __FILE__))
              run_generator [name, mod]
            end

            after :each do
              ::FileUtils.rm(::File.expand_path("../../tmp/spec/rails_helper.rb", __FILE__))
            end

            it "should create a namespaced presenter spec" do
              assert_file "spec/presenters/#{module_name_for_path(mod)}/#{name.underscore}_presenter_spec.rb", <<-CONTENTS
require 'rails_helper'

describe #{mod}::#{name.camelize}Presenter do

end
              CONTENTS
            end
          end
        end
      end
    end
  end
end
