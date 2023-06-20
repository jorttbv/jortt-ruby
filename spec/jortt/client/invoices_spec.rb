# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Invoices, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  describe '#index' do
    context 'pagination', vcr: false do
      subject { client.invoices.index }

      before do
        VCR.turn_off!

        stub_request(:any, 'https://app.jortt.nl/oauth-provider/oauth/token')
          .to_return(
            headers: {content_type: 'application/json'},
            body: {access_token: 'abc'}.to_json,
          )

        stub_request(:get, 'https://api.jortt.nl/invoices?invoice_status&page=1&query')
          .to_return(
            headers: {content_type: 'application/json'},
            body: {
              'data': [{id: 1}, {id: 2}],
              _links: {next: 'https://api.jortt.nl/invoices?page=2'},
            }.to_json,
          )

        stub_request(:get, 'https://api.jortt.nl/invoices?invoice_status&page=2&query')
          .to_return(
            headers: {content_type: 'application/json'},
            body: {
              data: [{id: 3}, {id: 4}],
              _links: {next: 'https://api.jortt.nl/invoices?page=3'},
            }.to_json,
          )

        stub_request(:get, 'https://api.jortt.nl/invoices?invoice_status&page=3&query')
          .to_return(
            headers: {content_type: 'application/json'},
            body: {
              data: [{id: 5}],
              _links: {next: nil},
            }.to_json,
          )
      end

      after { VCR.turn_on! }

      it 'returns the first page' do
        expect(subject.first.fetch('id')).to eq(1)
      end

      it 'seamlessly returns results from the other pages' do
        expect(subject.to_a.count).to eq(5)
      end
    end

    context 'invoice_status' do
      subject { client.invoices.index(invoice_status: 'sent') }

      it 'returns those invoices' do
        expect(subject.count).to be > 0
        expect(subject.first.fetch('invoice_status')).to eq('sent')
      end
    end

    context 'query' do
      subject { client.invoices.index(query: 'Search target') }

      it 'returns the queried invoices' do
        expect(subject.first.dig('invoice_due_amount', 'value')).to eq('2415.16')
      end
    end
  end

  describe '#create' do
    let(:customer) { client.customers.create(is_private: true, customer_name: 'John Doe') }
    let(:params) do
      {
        customer_id: customer.fetch('id'),
        send_method: 'self',
        line_items: [
          {
            vat: 21,
            amount_per_unit: {
              value: 499,
              currency: 'EUR',
            },
            units: 4,
            description: 'Your product',
          },
        ],
      }
    end
    after { client.customers.delete(customer.fetch('id')) }

    subject { client.invoices.create(params) }

    it 'creates the invoice' do
      uuid_length = 36
      expect(subject['id'].length).to eq(uuid_length)
    end

    it 'sends invoice content in HTTP request body' do
      subject
      expect(WebMock).to have_requested(:post, 'https://api.jortt.nl/invoices').with(body: params)
    end
  end

  describe '#show' do
    let(:uuid) { client.invoices.index(query: 'Search target').first.fetch('id') }
    subject { client.invoices.show(uuid) }

    it 'returns the invoice' do
      expect(subject.dig('invoice_due_amount', 'value')).to eq('2415.16')
    end
  end

  describe '#download' do
    let(:uuid) { client.invoices.index(query: 'Download test').first.fetch('id') }
    subject { client.invoices.download(uuid) }

    it 'returns the invoice download link' do
      expect(subject.fetch('download_location')).to match(%r{https://files\.jortt\.nl/.*})
    end
  end

  describe '#credit' do
    let(:uuid) { client.invoices.index(query: 'Search target').first.fetch('id') }
    subject { client.invoices.credit(uuid, {send_method: 'self'}) }

    it 'credits the invoice' do
      uuid_length = 36
      expect(subject['id'].length).to eq(uuid_length)
    end
  end
end
