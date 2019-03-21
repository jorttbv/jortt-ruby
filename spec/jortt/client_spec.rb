require 'spec_helper'

describe Jortt::Client do
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
    let(:client) { described_class.new(base_url: 'foo', app_name: 'app', api_key: 'secret') }

    describe '#customers' do
      subject { client.customers }
      it { should be_instance_of(described_class::Customers) }
    end

    describe '#invoices' do
      subject { client.invoices }
      it { should be_instance_of(described_class::Invoices) }
    end

    describe '#invoice' do
      subject { client.invoice('foo') }
      it { should be_instance_of(described_class::Invoice) }
    end

    describe 'error responses' do
      before do
        stub_request(:get, 'http://foo/invoices/id/foo?format=pdf').
          to_return(status: 400, body: '{"errors":{"invoice_id":{"code":"not_found"}}}')
      end

      it 'wraps RestClient errors' do
        expect { client.invoices.download('foo') }.to raise_error(Jortt::Error)
      end

      it 'exposes the json errors' do
        begin
          client.invoices.download('foo')
        rescue Jortt::Error => error
          expect(error.errors).to eq({"invoice_id" => {"code" => "not_found"}})
        end
      end
    end
  end
end
