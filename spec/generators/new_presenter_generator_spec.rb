require 'spec_helper'
require 'rails/all'
require 'generator_spec/test_case'

describe Versionist::NewPresenterGenerator do
  include GeneratorSpec::TestCase

  destination File.expand_path("../../tmp", __FILE__)

  before :each do
    prepare_destination
  end

  context "core logic" do
    before :each do
      run_generator %w(foo v1)
    end

    it "should create a namespaced presenter" do
      assert_file "app/presenters/v1/foo_presenter.rb", <<-CONTENTS
class V1::FooPresenter

  def initialize(foo)
    @foo = foo
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
  end

  context "special characters in version name" do
    before :each do
      run_generator %w(foo v3.4.2)
    end

    it "should create a namespaced presenter" do
      assert_file "app/presenters/v3.4.2/foo_presenter.rb", <<-CONTENTS
class V3_4_2::FooPresenter

  def initialize(foo)
    @foo = foo
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
  end
end
