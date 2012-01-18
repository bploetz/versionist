require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewApiVersionGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
  end

  {"v1" => "V1", "v2" => "V2", "v2.1" => "V2_1"}.each do |ver, mod|
    context "#{ver} => #{mod}" do
      before :each do
        run_generator [ver, mod]
      end

      it "should create a namespaced controller directory" do
        assert_directory "app/controllers/#{mod.underscore}"
      end

      it "should create a namespaced base controller" do
        assert_file "app/controllers/#{mod.underscore}/base_controller.rb", <<-CONTENTS
class #{mod}::BaseController < ApplicationController
end
        CONTENTS
      end

      it "should create a namespaced presenters directory" do
        assert_directory "app/presenters/#{mod.underscore}"
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
    <link href="default.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <h1>Documentation for #{ver}</h1>
  </body>
</html>
        CONTENTS
      end

      it "should create a documentation style.css" do
        assert_file "public/docs/#{ver}/style.css", <<-CONTENTS
body {background-color: #fff; color: #000;}
        CONTENTS
      end
    end
  end
end
