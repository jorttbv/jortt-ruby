require "spec_helper"

describe Freemle::Resource do
  let(:client) do
    double("client", base_url: "foo", app_name: "app", api_key: "secret")
  end
  let(:resource) { Freemle::Resource.new(client, :customer, :customers) }

  describe "#search" do
    subject { resource.search("query") }

    before do
      stub_request(:get, "http://app:secret@foo/customers").
        to_return(status: 200, body: '{"customers": []}')
    end

    it { should eq("customers" => []) }
  end

  describe "#create" do
    subject { resource.create(foo: :bar) }

    before do
      stub_request(:post, "http://app:secret@foo/customers").
        with(body: '{"customer":{"foo":"bar"}}').
        to_return(status: 201, body: '{"customer_id": "123"}')
    end

    it { should eq("customer_id" => "123") }
  end
end
