require 'spec_helper'

describe Jortt::Client::Invoice do
  let(:invoice) do
    described_class.new(
      double(base_url: 'foo', app_name: 'app', api_key: 'secret'),
      'bar',
    )
  end

  describe '#send_invoice' do
    let(:request_body) { JSON.generate(mail_data: {to: 'ben@jortt.nl'}) }
    let(:response_body) { JSON.generate(invoice_number: '2016-001') }
    subject { invoice.send_invoice(mail_data: {to: 'ben@jortt.nl'}) }
    before do
      stub_request(:post, 'http://foo/invoices/id/bar/send').
        with(body: request_body).
        to_return(status: 200, body: response_body)
    end
    it { should eq('invoice_number' => '2016-001') }
  end

  describe '#credit_invoice' do
    let(:args) { {invoice_date: Date.today, payment_term: 7} }
    before do
      stub_request(:post, 'http://foo/invoices/id/bar/credit')
        .with(body: JSON.generate(args))
        .to_return(status: 200, body: '{"credit_invoice_id": "CREDIT_INVOICE_ID"}')
    end

    it 'creates a draft credit invoice' do
      res = invoice.credit_invoice(args)
      expect(res["credit_invoice_id"]).to eq('CREDIT_INVOICE_ID')
    end
  end
end
