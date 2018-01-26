# encoding: UTF-8
require 'spec_helper'

describe Jortt::Client::Customers do
  let(:customers) do
    described_class.new(
      double(base_url: 'foo', app_name: 'app', api_key: 'secret'),
    )
  end

  describe '#all' do
    context 'without params' do
      subject { customers.all }

      before do
        url = 'http://foo/customers/all?page=1&per_page=50'
        stub_request(:get, url).
          to_return(status: 200, body: '{"customers": ["foo"]}')
      end

      it { should eq('customers' => ['foo']) }
    end

    context 'with params' do
      subject { customers.all(page: page, per_page: per_page) }
      let(:page) { 3 }
      let(:per_page) { 25 }

      before do
        url = 'http://foo/customers/all?page=3&per_page=25'
        stub_request(:get, url).
          to_return(status: 200, body: '{"customers": ["bar"]}')
      end

      it { should eq('customers' => ['bar']) }
    end
  end

  describe '#create' do
    let(:request_body) { JSON.generate(customer: {line_items: []}) }
    let(:response_body) { JSON.generate(customer_id: 'abc') }
    subject { customers.create(line_items: []) }
    before do
      stub_request(:post, 'http://foo/customers').
        with(body: request_body).
        to_return(status: 200, body: response_body)
    end
    it { should eq('customer_id' => 'abc') }
  end

  describe '#search' do
    subject { customers.search('terms') }
    before do
      stub_request(:get, 'http://foo/customers?query=terms').
        to_return(status: 200, body: '{"customers": []}')
    end
    it { should eq('customers' => []) }
  end
end
