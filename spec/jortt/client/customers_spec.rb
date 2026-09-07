# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Customers, :vcr do
  let(:client) { jortt_client }

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
        names = subject.map { |customer| customer['customer_name'] }
        expect(names).to include('Jane Doe', 'John Doe', 'Search target')
      end
    end

    context 'query' do
      subject { client.customers.index(query: 'Search target').to_a }

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
        expect(WebMock).to have_requested(:post, "#{jortt_site_url}/v3/customers").with(body: params)
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

  describe '#vats' do
    subject { client.customers.vats(jane) }

    it 'returns the vats' do
      expect(subject).to eq(
        {
          'id' => jane,
          'vats' => [
            {'value' => '0.21', 'category' => nil},
            {'value' => '0.09', 'category' => nil},
          ],
        },
      )
    end
  end
end

# Kept out of the :vcr describe above on purpose: its let! blocks create and delete customers
# for every example, and this one needs no HTTP at all.
describe Jortt::Client::Customers do
  # 7.0 renamed this method and UPGRADING.md promises the old name keeps working. The alias
  # resolves to the very method #vats exercises, so this is a complete proof of the promise
  # without a second round trip to the same endpoint.
  it 'still exposes vats under its former name' do
    expect(described_class.instance_method(:vat_percentages).original_name).to eq(:vats)
  end
end
