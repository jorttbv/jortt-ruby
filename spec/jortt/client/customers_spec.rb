# encoding: UTF-8
require 'spec_helper'

describe Jortt::Client::Customers do
  let(:customers) do
    described_class.new(
      double(base_url: 'foo', app_name: 'app', api_key: 'secret'),
    )
  end

  describe '#create' do
    let(:request_body) { JSON.generate(customer: {line_items: []}) }
    let(:response_body) { JSON.generate(customer_id: 'abc') }
    subject { customers.create(line_items: []) }
    before do
      stub_request(:post, 'http://app:secret@foo/customers').
        with(body: request_body).
        to_return(status: 200, body: response_body)
    end
    it { should eq('customer_id' => 'abc') }
  end

  describe '#search' do
    subject { customers.search('terms') }
    before do
      stub_request(:get, 'http://app:secret@foo/customers?query=terms').
        to_return(status: 200, body: '{"customers": []}')
    end
    it { should eq('customers' => []) }
  end
end
