# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe Jortt::Client, :vcr do
  context 'client credentials grant type' do
    # This spec does not read DEFAULT_SCOPE. An update to DEFAULT_SCOPE requires an update here as well.
    let(:scope) do
      'invoices:read invoices:write customers:read customers:write organizations:read expenses:read'
    end
    let!(:client) { jortt_client }

    it 'requests access token' do
      expect(WebMock).to have_requested(:post, "#{jortt_oauth_provider_url}/token").with(
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
    let(:refresh_token) { SecureRandom.hex(10) }
    let(:expires_at) { (Time.now + 7200).to_i }
    # Any string would prove the client stores what it is handed, but a fabricated token and a
    # made up customer both make the recorded request fail, which is a poor fixture. Borrow a
    # token the provider issued and a customer that exists, so the recording is a real 200.
    let(:api) { jortt_client }
    let(:access_token) { api.token.token }
    let(:customer_id) { api.customers.create(is_private: true, customer_name: 'Jane Doe').fetch('id') }
    after { api.customers.delete(customer_id) }
    let!(:client) do
      described_class.new(
        ENV['JORTT_CLIENT_ID'],
        ENV['JORTT_CLIENT_SECRET'],
        site: jortt_site_url,
        oauth_provider_url: jortt_oauth_provider_url,
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
      client.customers.show(customer_id)

      expect(WebMock).to have_requested(
        :get, "#{jortt_site_url}/v3/customers/#{customer_id}"
      ).with(
        headers: {
          Authorization: "Bearer #{access_token}",
        },
      )
    end
  end
end
