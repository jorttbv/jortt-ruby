# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Organizations, :vcr do
  let(:client) { jortt_client }

  describe '#me' do
    subject { client.organizations.me }

    it 'returns the logged in organization' do
      expect(subject).to include(
        'id' => '29d26011-51ed-418d-a9f2-2e55349d37d6',
        'company_name' => 'jortt-ruby gem',
      )
    end
  end
  describe '#create' do
    let(:params) do
      {
        email: "info@example.com",
        shop: 'the-shop',
        first_name: "John",
        last_name: "Doe"
       }
    end

    subject { client.organizations.create(params) }

    it 'creates the organization' do
      uuid_length = 36
      expect(subject['id'].length).to eq(uuid_length)
    end
  end
end
