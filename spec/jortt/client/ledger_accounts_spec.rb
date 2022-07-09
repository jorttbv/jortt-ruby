# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::LedgerAccounts, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  describe '#index' do
    subject { client.ledger_accounts.index }

    it 'returns invoices' do
      expect(subject.count).to be > 0
      expect(subject.first).to eq(
        'ledger_account_id' => '05a59e27-489f-466d-adf7-fc06f576d4ec',
        'name' => 'Omzet',
        'parent_ledger_account_id' => '105ea7d7-8bb5-499e-9823-8324826b6563',
        'selectable' => false,
      )
    end
  end
end
