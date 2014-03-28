require "spec_helper"

describe Freemle::Client do

  before do
    Freemle::Client.base_url = "https://www.freemle.com/api"
    Freemle::Client.app_name = "application"
    Freemle::Client.api_key = "key"
  end

  describe "searching for customers" do
    it "return empty list when no customers are found" do
      stub_request(:get, /.*\/api\/customers\?company_name=foo/).
        with(:headers => {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5'}).
        to_return(status: 200, body: {customers: []}.to_json)

      actual = Freemle::Client.find_customers "foo"
      actual.should == []
    end

    it "should return the customers as hashes" do
      stub_request(:get, /.*\/api\/customers\?company_name=foo/).
        with(:headers => {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5'}).
        to_return(status: 200, body: {customers: [{name: "foo"}, {name: "foobar"}]}.to_json)
      actual = Freemle::Client.find_customers "foo"
      actual.should == [{"name" => "foo"}, {"name" => "foobar"}]

    end

    it "should raise unauthorized when basic authentication fails" do
      stub_request(:get, /.*\/api\/customers\?company_name=foo/).to_return(status: 401)
      expect { Freemle::Client.find_customers("foo") }.to raise_error Freemle::Client::UnauthorizedError
    end

    it "should raise server error when 500 is returned" do
      stub_request(:get, /.*\/api\/customers\?company_name=foo/).to_return(status: 500)
      expect { Freemle::Client.find_customers("foo") }.to raise_error Freemle::Client::ServerError
    end

  end

  describe "creating customers" do
    before :each do
      @customer = {name: "foo"}
      @customer_id = "abc"
    end

    it "should return the id of the customer when successfully created" do
      stub_request(:post, /.*\/api\/customers/).
        with(headers: {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5', 'Content-Type' => 'application/json'}, body: {customer: @customer}.to_json).
        to_return(status: 201, body: {customer_id: @customer_id}.to_json)
      actual = Freemle::Client.create_customer(@customer)
      actual.should == @customer_id
    end

    it "should raise unauthorized when basic authentication fails" do
      stub_request(:post, /.*\/api\/customers/).with(body: {customer: @customer}.to_json).to_return(status: 401)
      expect { Freemle::Client.create_customer(@customer) }.to raise_error Freemle::Client::UnauthorizedError
    end

    it "should raise server error when 500 is returned" do
      stub_request(:post, /.*\/api\/customers/).with(headers: {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5', 'Content-Type' => 'application/json'}, body: {customer: @customer}.to_json).to_return(status: 500)
      expect { Freemle::Client.create_customer(@customer) }.to raise_error Freemle::Client::ServerError
    end
  end

  describe "creating invoices" do
    before :each do
      @invoice = {amount: 500}
      @invoice_id = "cba"
    end

    it "should return the id of the invoice when successfully created" do
      stub_request(:post, /.*\/api\/invoices/).
        with(headers: {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5', 'Content-Type' => 'application/json'}, body: {invoice: @invoice}.to_json).
        to_return(status: 201, body: {invoice_id: @invoice_id}.to_json)
      actual = Freemle::Client.create_invoice(@invoice)
      actual.should == @invoice_id
    end

    it "should return list of errors when making a bad request" do
      errors = {"invoice_date" => {"code" => "invalid"}}
      stub_request(:post, /.*\/api\/invoices/).
        with(headers: {'Authorization' => 'Basic YXBwbGljYXRpb246a2V5', 'Content-Type' => 'application/json'}, body: {invoice: @invoice}.to_json).
        to_return(status: 400, body: {errors: errors}.to_json)
      expect { Freemle::Client.create_invoice(@invoice) }.to raise_error { |error|
        error.should be_a(Freemle::Client::BadRequest)
        error.errors.should == errors
      }
    end
  end

end
