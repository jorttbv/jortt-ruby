# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe Jortt::Client, :vcr do
  context 'client credentials grant type' do
    let(:scope) { 'invoices:read invoices:write customers:read customers:write organizations:read' }
    let!(:client) { described_class.new(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

    it 'requests access token' do
      expect(WebMock).to have_requested(:post, 'https://app.jortt.nl/oauth-provider/oauth/token').with(
        body: {
          grant_type: 'client_credentials',
          scope: scope,
        },
      )
    end

    it 'configures oauth2 client' do
      expect(client.token.options[:header_format]).to start_with 'Bearer'
      expect(client.token.params['scope']).to eq scope
      expect(client.token.token).to eq 'access_token'
      expect(client.token.expires_at).to be_within(1).of((Time.now + 7200).to_i)
    end

    describe '#customers' do
      subject { client.customers }
      it { should be_instance_of(described_class::Customers) }
    end

    describe '#invoices' do
      subject { client.invoices }
      it { should be_instance_of(described_class::Invoices) }
    end

    describe '#ledger_accounts' do
      subject { client.ledger_accounts }
      it { should be_instance_of(described_class::LedgerAccounts) }
    end
  end

  context 'authorization code grant type' do
    let(:scope) { 'invoices:read organizations:read' }
    let(:access_token) { SecureRandom.hex(10) }
    let(:refresh_token) { SecureRandom.hex(10) }
    let(:expires_at) { (Time.now + 7200).to_i }
    let!(:client) do
      described_class.new(
        ENV['JORTT_CLIENT_ID'],
        ENV['JORTT_CLIENT_SECRET'],
        scope: scope,
        access_token: access_token,
        refresh_token: refresh_token,
        expires_at: expires_at,
      )
    end

    it 'configures oauth2 client' do
      expect(client.token.options[:header_format]).to start_with 'Bearer'
      expect(client.token.params[:scope]).to eq scope
      expect(client.token.token).to eq access_token
      expect(client.token.refresh_token).to eq refresh_token
      expect(client.token.expires_at).to eq expires_at
    end

    it 'uses access token in requests to API' do
      client.customers.show('9afcd96e-caf8-40a1-96c9-1af16d0bc804')

      expect(WebMock).to have_requested(:get, 'https://api.jortt.nl/customers/9afcd96e-caf8-40a1-96c9-1af16d0bc804').with(
        headers: {
          Authorization: "Bearer #{access_token}",
        },
      )
    end
  end
end
