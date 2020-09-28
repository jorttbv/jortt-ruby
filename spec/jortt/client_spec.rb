require 'spec_helper'

describe Jortt::Client, :vcr do
  context 'configured' do
    let(:client) { described_class.new(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

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
end
