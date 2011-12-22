require 'spec_helper'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../test-api/config/application", __FILE__)
TestApi::Application.initialize!

require 'rspec/rails'

describe Versionist::Routing do
  include RSpec::Rails::RequestExampleGroup

  context "header strategy" do
    context "version" do
      before :each do
        Versionist.configure do |config|
          config.versioning_strategy = "header", {:header => "Accept", :template => "application/vnd.mycompany.com-<%=version%>"}
          config.default_version = "v1"
        end

        TestApi::Application.routes.draw do
          scope :module => "v1", :constraints => api_version("v1") do
            match '/foos.(:format)' => 'foos#index', :via => :get
          end
        end
      end

      it "should not route to the correct controller when header isn't present" do
        @headers ||= {}
        begin
          get "/foos.json", nil, @headers
        rescue => err
          print err.message
          print err.backtrace.join("\n")
        end
        assert_response 404
      end

      it "should route to the correct controller when the header doesn't match" do
        @headers ||= {}
        @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v3"
        begin
          get "/foos.json", nil, @headers
        rescue => err
          print err.message
          print err.backtrace.join("\n")
        end
        assert_response 404
      end

      it "should route to the correct controller when header matches" do
        @headers ||= {}
        @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v1"
        begin
          get "/foos.json", nil, @headers
        rescue => err
          print err.message
          print err.backtrace.join("\n")
        end
        assert_response 200
        assert_equal 'application/json', response.content_type
        assert_equal "v1", response.body
      end
    end
  end

  context "url strategy" do
    it "should route to the correct controller" do
      
    end
  end
end
