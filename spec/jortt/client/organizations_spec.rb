# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Organizations, :vcr do
  let(:client) { jortt_client }

  describe '#me' do
    subject { client.organizations.me }

    it 'returns the logged in organization' do
      expect(subject).to include(
        'id' => '2af412cf-23f8-4b0d-9df2-a1afaf0ce67f',
        'company_name' => 'Jortt MKB B.V.',
      )
    end
  end
end
