require 'spec_helper'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../test-api/config/application", __FILE__)
TestApi::Application.initialize!

require 'rspec/rails'

describe Versionist::Routing do
  include RSpec::Rails::RequestExampleGroup

  context "#api_version" do
    after :each do
      Versionist.configuration.versioning_strategies.clear
    end

    it "should raise an error when config nil" do
      lambda {
        TestApi::Application.routes.draw do
          scope :module => "v1", :constraints => api_version(nil)
        end
      }.should raise_error(ArgumentError, /you must pass a configuration Hash to api_version/)
    end

    it "should raise an error when config is not a Hash" do
      lambda {
        TestApi::Application.routes.draw do
          scope :module => "v1", :constraints => api_version(1)
        end
      }.should raise_error(ArgumentError, /you must pass a configuration Hash to api_version/)
    end

    it "should raise an error when config doesn't contain any supported strategies" do
      lambda {
        TestApi::Application.routes.draw do
          scope :module => "v1", :constraints => api_version({})
        end
      }.should raise_error(ArgumentError, /you must specify :header, :path, or :parameter in configuration Hash passed to api_version/)
    end

    it "should add the middleware" do
      TestApi::Application.routes.draw do
        scope :module => "v1", :constraints => api_version({:header => "Accept", :value => "application/vnd.mycompany.com-v1"}) do
          match '/foos.(:format)' => 'foos#index', :via => :get
          match '/foos_no_format' => 'foos#index', :via => :get
          resources :bars
        end
        match '/foos(:format)' => 'foos#index', :via => :get
      end
      TestApi::Application.config.middleware.should include(Versionist::Middleware) 
    end

    context "default version" do
      it "should route to the default when no version given"
    end

    context ":header" do
      context "Accept" do
        before :each do
          TestApi::Application.routes.draw do
            scope :module => "v1", :constraints => api_version({:header => "Accept", :value => "application/vnd.mycompany.com-v1"}) do
              match '/foos.(:format)' => 'foos#index', :via => :get
              match '/foos_no_format' => 'foos#index', :via => :get
              resources :bars
            end
            match '/foos(:format)' => 'foos#index', :via => :get
            match '*a', :to => 'application#not_found'
          end
        end

        it "should not route when header isn't present" do
          @headers ||= {}
          get "/foos.json", nil, @headers
          assert_response 404
        end

        it "should not route when header doesn't match" do
          @headers ||= {}
          @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v3"
          get "/foos.json", nil, @headers
          assert_response 404
        end

        it "should route to the correct controller when header matches" do
          @headers ||= {}
          @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v1"
          get "/foos.json", nil, @headers
          assert_response 200
          assert_equal 'application/json', response.content_type
          assert_equal "v1", response.body

          get "/foos.xml", nil, @headers
          assert_response 200
          assert_equal 'application/xml', response.content_type
          assert_equal "v1", response.body
        end

        it "should route to the correct controller when format specified via accept header" do
          @headers ||= {}
          @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v1,application/json"
          get "/foos_no_format", nil, @headers
          assert_response 200
          assert_equal 'application/json', response.content_type
          assert_equal "v1", response.body

          @headers ||= {}
          @headers["HTTP_ACCEPT"] = "application/xml, application/vnd.mycompany.com-v1"
          get "/foos_no_format", nil, @headers
          assert_response 200
          assert_equal 'application/xml', response.content_type
          assert_equal "v1", response.body

          @headers ||= {}
          @headers["HTTP_ACCEPT"] = "application/xml, application/vnd.mycompany.com-v1, application/json"
          get "/foos_no_format", nil, @headers
          assert_response 200
          assert_equal 'application/xml', response.content_type
          assert_equal "v1", response.body
        end
      end
    end

    context ":path" do
    end

    context ":parameter" do
    end
  end
end
