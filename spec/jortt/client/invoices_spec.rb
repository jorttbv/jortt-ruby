# encoding: UTF-8
require 'spec_helper'

describe Jortt::Client::Invoices do
  let(:invoices) do
    described_class.new(
      double(base_url: 'foo', app_name: 'app', api_key: 'secret'),
    )
  end

  describe '#create' do
    let(:request_body) { JSON.generate(invoice: {line_items: []}) }
    let(:response_body) { JSON.generate(invoice_id: 'abc') }
    subject { invoices.create(line_items: []) }
    before do
      stub_request(:post, 'http://app:secret@foo/invoices').
        with(body: request_body).
        to_return(status: 200, body: response_body)
    end
    it { should eq('invoice_id' => 'abc') }
  end
end
