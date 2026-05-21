# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Expenses do
  let(:client) { jortt_client }

  before do
    VCR.turn_off!

    stub_request(:any, 'https://app.jortt.nl/oauth-provider/oauth/token')
      .to_return(
        headers: {content_type: 'application/json'},
        body: {access_token: 'abc'}.to_json,
      )
  end

  after { VCR.turn_on! }

  describe '#index' do
    before do
      stub_request(
        :get,
        'https://api.jortt.nl/v3/expenses?page=1&vat_date_from=20260101&vat_date_till=20260331',
      ).to_return(
        headers: {content_type: 'application/json'},
        body: {
          data: [{id: 1}, {id: 2}],
          _links: {next: 'https://api.jortt.nl/v3/expenses?page=2'},
        }.to_json,
      )

      stub_request(
        :get,
        'https://api.jortt.nl/v3/expenses?page=2&vat_date_from=20260101&vat_date_till=20260331',
      ).to_return(
        headers: {content_type: 'application/json'},
        body: {
          data: [{id: 3}],
          _links: {next: nil},
        }.to_json,
      )
    end

    subject do
      client.expenses.index(
        vat_date_from: '20260101',
        vat_date_till: '20260331',
      )
    end

    it 'paginates through all pages' do
      expect(subject.to_a.count).to eq(3)
    end

    it 'omits parameters that are nil' do
      stub_request(:get, 'https://api.jortt.nl/v3/expenses?page=1')
        .to_return(
          headers: {content_type: 'application/json'},
          body: {data: [], _links: {next: nil}}.to_json,
        )

      client.expenses.index.to_a

      expect(WebMock).to have_requested(:get, 'https://api.jortt.nl/v3/expenses?page=1')
    end
  end

  describe '#show' do
    let(:id) { '9afcd96e-caf8-40a1-96c9-1af16d0bc804' }

    before do
      stub_request(:get, "https://api.jortt.nl/v3/expenses/id/#{id}")
        .to_return(
          headers: {content_type: 'application/json'},
          body: {data: {id: id, supplier_name: 'Acme Corp'}}.to_json,
        )
    end

    it 'returns the expense' do
      expect(client.expenses.show(id)).to include('supplier_name' => 'Acme Corp')
    end
  end

  describe '#create' do
    let(:payload) do
      {
        expense_date: '2026-01-15',
        vat_date: '2026-01-15',
        supplier_name: 'Acme Corp',
        line_items: [
          {
            amount: {value: '100.00', currency: 'EUR'},
            vat_percentage: '21.0',
          },
        ],
      }
    end

    before do
      stub_request(:post, 'https://api.jortt.nl/v3/expenses')
        .to_return(
          headers: {content_type: 'application/json'},
          body: {data: {id: 'expense-uuid'}}.to_json,
        )
    end

    it 'POSTs the payload as JSON' do
      client.expenses.create(payload)

      expect(WebMock).to have_requested(:post, 'https://api.jortt.nl/v3/expenses')
        .with(
          body: payload.to_json,
          headers: {'Content-Type' => 'application/json'},
        )
    end
  end

  describe '#update' do
    let(:id) { '9afcd96e-caf8-40a1-96c9-1af16d0bc804' }
    let(:payload) { {description: 'Updated'} }

    before do
      stub_request(:post, "https://api.jortt.nl/v3/expenses/id/#{id}")
        .to_return(
          headers: {content_type: 'application/json'},
          body: {data: {id: id}}.to_json,
        )
    end

    it 'POSTs to the expense id endpoint' do
      client.expenses.update(id, payload)

      expect(WebMock).to have_requested(:post, "https://api.jortt.nl/v3/expenses/id/#{id}")
        .with(body: payload.to_json)
    end
  end

  describe '#attach_receipt' do
    let(:id) { '9afcd96e-caf8-40a1-96c9-1af16d0bc804' }
    let(:payload) { {file_id: 'file-uuid'} }

    before do
      stub_request(:post, "https://api.jortt.nl/v3/expenses/id/#{id}/receipt")
        .to_return(
          headers: {content_type: 'application/json'},
          body: {data: {}}.to_json,
        )
    end

    it 'POSTs to the receipt endpoint' do
      client.expenses.attach_receipt(id, payload)

      expect(WebMock).to have_requested(:post, "https://api.jortt.nl/v3/expenses/id/#{id}/receipt")
        .with(body: payload.to_json)
    end
  end
end
