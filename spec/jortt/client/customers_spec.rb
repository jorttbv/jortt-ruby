# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Customers, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  let(:params) do
    {
      is_private: false,
      customer_name: 'Nuka-Cola Corporation',
      address_street: 'Vault 11',
      address_postal_code: '1111AA',
      address_city: 'Mojave Wasteland',
    }
  end

  let!(:jane) { client.customers.create(is_private: true, customer_name: 'Jane Doe')['id'] }
  let!(:john) { client.customers.create(is_private: true, customer_name: 'John Doe')['id'] }

  after do
    client.customers.delete(jane)
    client.customers.delete(john)
  end

  describe '#index' do
    context 'without params' do
      subject { client.customers.index.to_a }

      it 'returns customers' do
        expect(subject.count).to eq(3)
        expect(subject[0]['customer_name']).to eq('Jane Doe')
        expect(subject[1]['customer_name']).to eq('John Doe')
        expect(subject[2]['customer_name']).to eq('Search target')
      end
    end

    context 'query' do
      subject { client.customers.index(query: 'Search target') }

      it 'returns the queried customers' do
        expect(subject.count).to eq(1)
        expect(subject.first['customer_name']).to eq('Search target')
      end
    end
  end

  describe '#show' do
    subject { client.customers.show(jane) }

    it 'returns the customer' do
      expect(subject['customer_name']).to eq('Jane Doe')
    end
  end

  describe '#create' do
    context 'valid payload' do
      subject { client.customers.create(params) }
      after { client.customers.delete(subject['id']) }

      it 'creates the customer' do
        uuid_length = 36
        expect(subject['id'].length).to eq(uuid_length)
      end

      it 'sends customer parameters in HTTP request body' do
        subject
        expect(WebMock).to have_requested(:post, 'https://api.jortt.nl/customers').with(body: params)
      end
    end

    context 'faulty payload' do
      subject { client.customers.create({}) }

      it 'shows a nice error' do
        expect { subject }.to raise_error(Jortt::Client::Error)
      end
    end
  end

  describe '#update' do
    let(:uuid) { client.customers.create(params).fetch('id') }
    subject { client.customers.update(uuid, params.merge(address_extra_information: 'Extra...')) }
    after { client.customers.delete(uuid) }

    it 'updates the customer' do
      expect(subject).to eq(true)
    end
  end

  describe '#delete' do
    let(:uuid) { client.customers.create(params).fetch('id') }
    subject { client.customers.delete(uuid) }

    it 'deletes the customer' do
      expect(subject).to eq(true)
    end
  end

  describe '#direct_debit_mandate' do
    subject { client.customers.direct_debit_mandate(jane) }

    it 'sends direct debit mandate to the customer or responds with an error when not possible' do
      subject
    rescue Jortt::Client::Error => e
      expect(e.details.first['key']).to eq('DirectDebit::NotEnabled')
    end
  end

  describe '#vat_percentages' do
    subject { client.customers.vat_percentages(jane) }

    it 'returns the vat percentages' do
      expect(subject).to eq(
        {
          'id' => '546a86e8-7a57-4d46-9a81-09378a399dd9',
          'vat_percentages' => {
            'reduced_rate' => ['9.0', '0.0'],
            'standard_rate' => '21.0',
          },
        },
      )
    end
  end
end
