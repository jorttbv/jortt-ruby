require 'spec_helper'

describe Freemle::Client do
  describe '#initialize' do
    subject { described_class.new(opts) }
    let(:opts) { {} }

    specify { expect { subject }.to raise_error(KeyError) }

    context 'given app_name' do
      before { opts[:app_name] = 'name' }

      specify { expect { subject }.to raise_error(KeyError) }

      context 'and api_key' do
        before { opts[:api_key] = 'secret' }
        it { should be_instance_of(described_class) }
        its(:base_url) { should eq(described_class::BASE_URL) }
        its(:app_name) { should eq('name') }
        its(:api_key) { should eq('secret') }
      end
    end
  end

  context 'configured' do
    let(:client) { described_class.new(app_name: 'app', api_key: 'secret') }

    describe '#customers' do
      subject { client.customers }
      it { should be_instance_of(described_class::Resource) }
      its(:singular) { should eq(:customer) }
      its(:plural) { should eq(:customers) }
    end

    describe '#invoices' do
      subject { client.invoices }
      it { should be_instance_of(described_class::Resource) }
      its(:singular) { should eq(:invoice) }
      its(:plural) { should eq(:invoices) }
    end
  end
end
