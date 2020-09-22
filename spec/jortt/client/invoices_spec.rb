require 'spec_helper'

describe Jortt::Client::Invoices, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  let(:customer) { client.customers.index(query: 'Search target').first }

  let(:params) do
    {
      customer_id: customer.fetch('id'),
      send_method: 'self',
      line_items: [{
        vat: 21,
        amount_per_unit: {
            value: 499,
            currency: 'EUR'
        },
        units: 4,
        description: 'Your product'
     }]
    }
  end

  describe '#index' do
    context 'without params' do
      subject { client.invoices.index }

      it "returns invoices" do
        expect(subject.count).to be > 0
        expect(subject.first.fetch('invoice_status')).to eq('sent')
      end
    end

    context 'pagination' do
      subject { client.invoices.index(page: 10000) }

      it "returns that page" do
        expect(subject.count).to eq(0)
      end
    end

    context 'invoice_status' do
      subject { client.invoices.index(invoice_status: 'sent') }

      it "returns that page" do
        expect(subject.count).to be > 0
      end
    end

    context 'query' do
      subject { client.invoices.index(query: 'Search target') }

      it "returns the queried invoices" do
        expect(subject.first.dig('invoice_due_amount', 'value')).to eq("2415.16")
      end
    end
  end

  describe '#create' do
    subject { client.invoices.create(params) }

    it "creates the invoice" do
      uuid_length = 36
      expect(subject['id'].length).to eq(uuid_length)
    end
  end

  describe '#show' do
    let(:uuid) { client.invoices.index(query: 'Search target').first.fetch('id') }
    subject { client.invoices.show(uuid) }

    it "returns the invoice" do
      expect(subject.dig('invoice_due_amount', 'value')).to eq("2415.16")
    end
  end

  describe '#download' do
    let(:uuid) { client.invoices.index(query: 'Download test').first.fetch('id') }
    subject { client.invoices.download(uuid) }

    it "returns the invoice download link" do
      expect(subject.fetch('download_location')).to match(/https:\/\/files\.jortt\.nl\/.*/)
    end
  end
end
