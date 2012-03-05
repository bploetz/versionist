require 'spec_helper'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../test-api/config/application", __FILE__)
TestApi::Application.initialize!

require 'rspec/rails'

describe Versionist::Routing do
  include RSpec::Rails::RequestExampleGroup

  context "#api_version" do
    before :each do
      Versionist.configuration.versioning_strategies.clear
      Versionist.configuration.default_version = nil
      Versionist.configuration.header_versions.clear
      TestApi::Application.routes.clear!
    end

    it "should raise an error when config nil" do
      lambda {
        TestApi::Application.routes.draw do
          api_version(nil)
        end
      }.should raise_error(ArgumentError, /you must pass a configuration Hash to api_version/)
    end

    it "should raise an error when config is not a Hash" do
      lambda {
        TestApi::Application.routes.draw do
          api_version(1)
        end
      }.should raise_error(ArgumentError, /you must pass a configuration Hash to api_version/)
    end

    it "should raise an error when config doesn't contain :module" do
      lambda {
        TestApi::Application.routes.draw do
          api_version({})
        end
      }.should raise_error(ArgumentError, /you must specify :module in configuration Hash passed to api_version/)
    end

    it "should raise an error when config doesn't contain any supported strategies" do
      lambda {
        TestApi::Application.routes.draw do
          api_version({:module => "v1"})
        end
      }.should raise_error(ArgumentError, /you must specify :header, :path, or :parameter in configuration Hash passed to api_version/)
    end

    it "should add the middleware" do
      TestApi::Application.routes.draw do
        api_version({:module => "v1", :header => "Accept", :value => "application/vnd.mycompany.com-v1"}) do
          match '/foos.(:format)' => 'foos#index', :via => :get
          match '/foos_no_format' => 'foos#index', :via => :get
          resources :bars
        end
        match '/foos(:format)' => 'foos#index', :via => :get
      end
      TestApi::Application.config.middleware.should include(Versionist::Middleware) 
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
                api_version({:module => mod, :header => "Accept", :value => "application/vnd.mycompany.com-#{ver}"}) do
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

            context ":default => true" do
              before :each do
                TestApi::Application.routes.draw do
                  api_version({:module => mod, :header => "Accept", :value => "application/vnd.mycompany.com-#{ver}", :default => true}) do
                    match '/foos.(:format)' => 'foos#index', :via => :get
                  end
                  api_version({:module => "not_default", :header => "Accept", :value => "application/vnd.mycompany.com-not_default"}) do
                    match '/foos.(:format)' => 'foos#index', :via => :get
                  end
                end
              end

              it "should route to the default when no version given" do
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal ver, response.body

                @headers["HTTP_ACCEPT"] = ""
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal ver, response.body

                @headers["HTTP_ACCEPT"] = "   "
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal ver, response.body
              end

              it "should not route to the default when another configured version is given" do
                @headers["HTTP_ACCEPT"] = "application/vnd.mycompany.com-not_default"
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal "not_default", response.body
              end
            end
          end

          context "custom header" do
            before :each do
              TestApi::Application.routes.draw do
                api_version({:module => mod, :header => "API-VERSION", :value => ver}) do
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
              @headers["API_VERSION"] = "v3"
              get "/foos.json", nil, @headers
              assert_response 404
            end

            it "should route to the correct controller when header matches" do
              @headers["HTTP_API_VERSION"] = ver
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
              @headers["HTTP_API_VERSION"] = ver
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              @headers["HTTP_ACCEPT"] = "application/xml,application/json"
              @headers["HTTP_API_VERSION"] = ver
              get "/foos_no_format", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end

            context ":default => true" do
              before :each do
                TestApi::Application.routes.draw do
                  api_version({:module => mod, :header => "API-VERSION", :value => ver, :default => true}) do
                    match '/foos.(:format)' => 'foos#index', :via => :get
                  end
                  api_version({:module => "not_default", :header => "API-VERSION", :value => "not_default"}) do
                    match '/foos.(:format)' => 'foos#index', :via => :get
                  end
                end
              end

              it "should route to the default when no version given" do
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal ver, response.body

                @headers["HTTP_API_VERSION"] = ""
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal ver, response.body

                @headers["HTTP_API_VERSION"] = "    "
                get "/foos.xml", nil, @headers
                assert_response 200
                assert_equal 'application/xml', response.content_type
                assert_equal ver, response.body
              end

              it "should not route to the default when another configured version is given" do
                @headers["HTTP_API_VERSION"] = "not_default"
                get "/foos.json", nil, @headers
                assert_response 200
                assert_equal 'application/json', response.content_type
                assert_equal "not_default", response.body
              end
            end
          end
        end

        context ":path" do
          before :each do
            TestApi::Application.routes.draw do
              api_version({:module => mod, :path => "/#{ver}"}) do
                match '/foos.(:format)' => 'foos#index', :via => :get
                match '/foos_no_format' => 'foos#index', :via => :get
                resources :bars
              end
              match '/foos(:format)' => 'foos#index', :via => :get
              match '*a', :to => 'application#not_found'
            end
          end

          it "should not route when path isn't present" do
            get "/foos.json", nil, @headers
            assert_response 404
          end

          it "should not route when path doesn't match" do
            get "/bogus/foos.json", nil, @headers
            assert_response 404
          end

          it "should route to the correct controller when path matches" do
            get "/#{ver}/foos.json", nil, @headers
            assert_response 200
            assert_equal 'application/json', response.content_type
            assert_equal ver, response.body

            get "/#{ver}/foos.xml", nil, @headers
            assert_response 200
            assert_equal 'application/xml', response.content_type
            assert_equal ver, response.body
          end

          it "should route to the correct controller when path matches and format specified via accept header" do
            @headers["HTTP_ACCEPT"] = "application/json,application/xml"
            get "/#{ver}/foos_no_format", nil, @headers
            assert_response 200
            assert_equal 'application/json', response.content_type
            assert_equal ver, response.body

            @headers["HTTP_ACCEPT"] = "application/xml,application/json"
            get "/#{ver}/foos_no_format", nil, @headers
            assert_response 200
            assert_equal 'application/xml', response.content_type
            assert_equal ver, response.body
          end

          context ":default => true" do
            before :each do
              TestApi::Application.routes.draw do
                api_version({:module => mod, :path => "/#{ver}", :default => true}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                end
                api_version({:module => "not_default", :path => "/not_default"}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                end
              end
            end

            it "should route to the default when no version given" do
              get "/foos.json", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              get "/foos.xml", nil, @headers
              assert_response 200
              assert_equal 'application/xml', response.content_type
              assert_equal ver, response.body
            end

            it "should not route to the default when another configured version is given" do
              get "/not_default/foos.json", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal "not_default", response.body
            end
          end
        end

        context ":parameter" do
          before :each do
            TestApi::Application.routes.draw do
              api_version({:module => mod, :parameter => "version", :value => ver}) do
                match '/foos.(:format)' => 'foos#index', :via => :get
                match '/foos_no_format' => 'foos#index', :via => :get
                resources :bars
              end
              match '/foos(:format)' => 'foos#index', :via => :get
              match '*a', :to => 'application#not_found'
            end
          end

          it "should not route when parameter isn't present" do
            get "/foos.json", nil, @headers
            assert_response 404
          end

          it "should not route when parameter doesn't match" do
            get "/foos.json?version=3", nil, @headers
            assert_response 404
          end

          it "should route to the correct controller when parameter matches" do
            get "/foos.json?version=#{ver}", nil, @headers
            assert_response 200
            assert_equal 'application/json', response.content_type
            assert_equal ver, response.body

            get "/foos.xml?version=#{ver}", nil, @headers
            assert_response 200
            assert_equal 'application/xml', response.content_type
            assert_equal ver, response.body
          end

          it "should route to the correct controller when parameter matches and format specified via accept header" do
            @headers["HTTP_ACCEPT"] = "application/json,application/xml"
            get "/foos_no_format?version=#{ver}", nil, @headers
            assert_response 200
            assert_equal 'application/json', response.content_type
            assert_equal ver, response.body

            @headers["HTTP_ACCEPT"] = "application/xml,application/json"
            get "/foos_no_format?version=#{ver}", nil, @headers
            assert_response 200
            assert_equal 'application/xml', response.content_type
            assert_equal ver, response.body
          end

          context ":default => true" do
            before :each do
              TestApi::Application.routes.draw do
                api_version({:module => mod, :parameter => "version", :value => ver, :default => true}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                end
                api_version({:module => "not_default", :parameter => "version", :value => "not_default"}) do
                  match '/foos.(:format)' => 'foos#index', :via => :get
                end
              end
            end

            it "should route to the default when no version given" do
              get "/foos.json", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body

              get "/foos.json?version=", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal ver, response.body
            end

            it "should not route to the default when another configured version is given" do
              get "/foos.json?version=not_default", nil, @headers
              assert_response 200
              assert_equal 'application/json', response.content_type
              assert_equal "not_default", response.body
            end
          end
        end
      end
    end
  end
end
