# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::LedgerAccounts, :vcr do
  let(:client) { jortt_client }

  describe '#index' do
    subject { client.ledger_accounts.index }

    it 'returns invoices' do
      expect(subject.count).to be > 0
      expect(subject.first).to eq(
        'ledger_account_id' => 'e52678ce-3d4e-4602-afb9-e825c245f716',
        'name' => 'Omzet',
        'parent_ledger_account_id' => '802de112-06b1-454b-b865-504027f44144',
        'selectable' => false,
      )
    end
  end
end
