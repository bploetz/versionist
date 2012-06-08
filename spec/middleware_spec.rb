require 'spec_helper'
require 'rack/test'

describe Versionist::Middleware do
  before :all do
    Versionist::VersioningStrategy::Header.new({:header => "Accept", :value => "application/vnd.mycompany.com-v2.3.0"})
    @app = lambda {|env| [200, {"Content-Type" => "text/plain"}, [env["HTTP_ACCEPT"]]]}
  end

  after :all do
    Versionist.configuration.clear!
  end

  context "Accept header" do
    it "should not alter the header if the version is not present" do
      request = Rack::MockRequest.env_for("/foos", "HTTP_ACCEPT" => "application/json", :lint => true, :fatal => true)
      status, headers, response = described_class.new(@app).call(request)
      response[0].should == "application/json"
    end

    it "should not alter the header if an unconfigured version is present" do
      request = Rack::MockRequest.env_for("/foos", "HTTP_ACCEPT" => "application/vnd.mycompany.com-v1,application/json", :lint => true, :fatal => true)
      status, headers, response = described_class.new(@app).call(request)
      response[0].should == "application/vnd.mycompany.com-v1,application/json"
    end

    it "should move the version to the end" do
      request = Rack::MockRequest.env_for("/foos", "HTTP_ACCEPT" => "application/vnd.mycompany.com-v2.3.0,application/json", :lint => true, :fatal => true)
      status, headers, response = described_class.new(@app).call(request)
      response[0].should == "application/json, application/vnd.mycompany.com-v2.3.0"
    end

    it "should move the version to the end and retain accept params" do
      request = Rack::MockRequest.env_for("/foos", "HTTP_ACCEPT" => "audio/*; q=0.2, audio/basic, application/vnd.mycompany.com-v2.3.0, application/json", :lint => true, :fatal => true)
      status, headers, response = described_class.new(@app).call(request)
      response[0].should == "audio/*; q=0.2, audio/basic, application/json, application/vnd.mycompany.com-v2.3.0"
    end

    it "should not alter the header if the accept header is not present" do
      request = Rack::MockRequest.env_for("/foos", :lint => true, :fatal => true)
      status, headers, response = described_class.new(@app).call(request)
      response[0].should be_nil
    end
  end
end
