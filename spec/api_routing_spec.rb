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

    {"v1" => "v1", "v2" => "v2", "v2.1" => "v2__1"}.each do |ver, mod|
      context ver do
        before :each do
          @headers = Hash.new
        end

        context ":header" do
          context "Accept" do
            before :each do
              TestApi::Application.routes.draw do
                scope :module => mod, :constraints => api_version({:header => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                  match '/foos_no_format' => 'foos#index', :via => :get
                  resources :bars
                end
                match '/foos(:format)' => 'foos#index', :via => :get
                match '*a', :to => 'application#not_found'
              end
            end

            it "should not route when header isn't present" do
              get "/foos.json", nil, @headers
              assert_response 404
            end

            it "should not route when header doesn't match" do
              @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v3"
              get "/foos.json", nil, @headers
              assert_response 404
            end

            it "should route to the correct controller when header matches" do
              @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-#{ver}"
              get "/foos.json", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              get "/foos.xml", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end

            it "should route to the correct controller when format specified via accept header" do
              @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-#{ver},application/json"
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              @headers["HTTP_ACCEPT"] = "application/xml, application/vnd.mycompany.com-#{ver}"
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body

              @headers["HTTP_ACCEPT"] = "application/xml, application/vnd.mycompany.com-#{ver}, application/json"
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end
          end

          context "custom header" do
            before :each do
              TestApi::Application.routes.draw do
                scope :module => mod, :constraints => api_version({:header => "X-MY-CUSTOM-HEADER", :value => ver}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                  match '/foos_no_format' => 'foos#index', :via => :get
                  resources :bars
                end
                match '/foos(:format)' => 'foos#index', :via => :get
                match '*a', :to => 'application#not_found'
              end
            end

            it "should not route when header isn't present" do
              get "/foos.json", nil, @headers
              assert_response 404
            end

            it "should not route when header doesn't match" do
              @headers["HTTP_X_MY_CUSTOM_HEADER"] = "v3"
              get "/foos.json", nil, @headers
              assert_response 404
            end

            it "should route to the correct controller when header matches" do
              @headers["HTTP_X_MY_CUSTOM_HEADER"] = ver
              get "/foos.json", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              get "/foos.xml", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end

            it "should route to the correct controller when format specified via accept header" do
              @headers["HTTP_ACCEPT"] = "application/json,application/xml"
              @headers["HTTP_X_MY_CUSTOM_HEADER"] = ver
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              @headers["HTTP_ACCEPT"] = "application/xml,application/json"
              @headers["HTTP_X_MY_CUSTOM_HEADER"] = ver
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end
          end
        end

        context ":path" do
        end

        context ":parameter" do
        end
      end
    end
  end
end
