require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewApiVersionGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
  end

  context "core logic" do
    before :each do
      run_generator %w(v1)
    end

    it "should create a namespaced controller directory" do
      assert_directory "app/controllers/v1"
    end

    it "should create a namespaced base controller" do
      assert_file "app/controllers/v1/base_controller.rb", <<-CONTENTS
class V1::BaseController < ApplicationController
end
      CONTENTS
    end

    it "should create a namespaced presenters directory" do
      assert_directory "app/presenters/v1"
    end

    it "should create a documentation directory" do
      assert_directory "public/docs/v1"
    end

    it "should create a documentation index.html" do
      assert_file "public/docs/v1/index.html", <<-CONTENTS
<!DOCTYPE html>
<html lang="en-US">
  <head>
    <title>Documentation for v1</title>
    <link href="default.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <h1>Documentation for v1</h1>
  </body>
</html>
      CONTENTS
    end

    it "should create a documentation style.css" do
      assert_file "public/docs/v1/style.css", <<-CONTENTS
body {background-color: #fff; color: #000;}
      CONTENTS
    end
  end

  context "special characters in version name" do
    before :each do
      run_generator %w(v3.4.2)
    end

    it "should create a namespaced controller directory" do
      assert_directory "app/controllers/v3.4.2"
    end

    it "should create a namespaced base controller replacing non word characters with underscores" do
      assert_file "app/controllers/v3.4.2/base_controller.rb", <<-CONTENTS
class V3_4_2::BaseController < ApplicationController
end
      CONTENTS
    end

    it "should create a namespaced presenters directory" do
      assert_directory "app/presenters/v3.4.2"
    end

    it "should create a documentation directory" do
      assert_directory "public/docs/v3.4.2"
    end
  end
end
