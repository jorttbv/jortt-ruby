# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Organizations, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  describe '#me' do
    subject { client.organizations.me }

    it 'returns the logged in organization' do
      expect(subject).to include(
        'id' => '29d26011-51ed-418d-a9f2-2e55349d37d6',
        'company_name' => 'jortt-ruby gem',
      )
    end
  end
end
