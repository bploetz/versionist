require 'spec_helper'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../test-api/config/application", __FILE__)

require 'rspec/rails'

describe Versionist::Routing do
  include RSpec::Rails::RequestExampleGroup

  context "#api_version" do
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

    context ":header" do
      it "should add the accept header middleware if the header is Accept" do
        TestApi::Application.routes.draw do
          scope :module => "v1", :constraints => api_version({:header => "Accept", :value => "application/vnd.mycompany.com-v1"}) do
            match '/foos.(:format)' => 'foos#index', :via => :get
            match '/foos_no_format' => 'foos#index', :via => :get
            resources :bars
          end
          match '/foos(:format)' => 'foos#index', :via => :get
        end
        TestApi::Application.initialize!
        TestApi::Application.config.middleware.should include(Versionist::Middleware) 
      end
    end

    context ":path" do
    end

    context ":parameter" do
    end

    # before :each do
      # TestApi::Application.routes.draw do
        # scope :module => "v1", :constraints => api_version(:version => "v1", :header => "Accept", :template => "application/vnd.mycompany.com-<%=version%>") do
          # match '/foos.(:format)' => 'foos#index', :via => :get
          # match '/foos_no_format' => 'foos#index', :via => :get
          # resources :bars
        # end
        # match '*a', :to => 'application#not_found'
      # end
    # end
  end

  # context "header strategy" do
    # context "Accept header" do
      # before :each do
        # Versionist.configure do |config|
          # config.versioning_strategy = "header", {:header => "Accept", :template => "application/vnd.mycompany.com-<%=version%>"}
          # config.default_version = "v1"
        # end
# 
        # TestApi::Application.routes.draw do
          # scope :module => "v1", :constraints => api_version("v1") do
            # match '/foos.(:format)' => 'foos#index', :via => :get
            # match '/foos_no_format' => 'foos#index', :via => :get
          # end
          # match '*a', :to => 'application#not_found'
        # end
      # end
# 
      # it "should not route when the configured header isn't present" do
        # @headers ||= {}
        # get "/foos.json", nil, @headers
        # assert_response 404
      # end
# 
      # it "should not route when the header doesn't match" do
        # @headers ||= {}
        # @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v3"
        # get "/foos.json", nil, @headers
        # assert_response 404
      # end
# 
      # it "should route to the correct controller when header matches" do
        # @headers ||= {}
        # @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v1"
        # get "/foos.json", nil, @headers
        # assert_response 200
        # assert_equal 'application/json', response.content_type
        # assert_equal "v1", response.body
      # end
# 
      # it "should route to the correct controller when format specified via accept header" do
        # @headers ||= {}
        # @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-v1,application/json"
        # get "/foos_no_format", nil, @headers
        # assert_response 200
        # assert_equal 'application/json', response.content_type
        # assert_equal "v1", response.body
      # end
    # end
# 
    # context "custom header" do
      # before :each do
        # Versionist.configure do |config|
          # config.versioning_strategy = "header", {:header => "X-MY-CUSTOM-HEADER", :template => "<%=version%>"}
          # config.default_version = "v1"
        # end
# 
        # TestApi::Application.routes.draw do
          # scope :module => "v1", :constraints => api_version("v1") do
            # match '/foos.(:format)' => 'foos#index', :via => :get
            # match '/foos_no_format' => 'foos#index', :via => :get
          # end
          # match '*a', :to => 'application#not_found'
        # end
      # end
# 
      # it "should not route when the configured header isn't present" do
        # @headers ||= {}
        # get "/foos.json", nil, @headers
        # assert_response 404
      # end
# 
      # it "should not route when the header doesn't match" do
        # @headers ||= {}
        # @headers["HTTP_X_MY_CUSTOM_HEADER"] = "v3"
        # get "/foos.json", nil, @headers
        # assert_response 404
      # end
# 
      # it "should route to the correct controller when header matches" do
        # @headers ||= {}
        # @headers["HTTP_X_MY_CUSTOM_HEADER"] = "v3"
        # get "/foos.json", nil, @headers
        # assert_response 200
        # assert_equal 'application/json', response.content_type
        # assert_equal "v3", response.body
      # end
    # end
  # end

  context "path strategy" do
    it "should route to the correct controller"
  end

  context "query string strategy" do
    it "should route to the correct controller"
  end
end
