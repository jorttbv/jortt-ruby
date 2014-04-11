require "spec_helper"

describe Freemle::Client do

  describe "#initialize" do
    subject { Freemle::Client.new(opts) }
    let(:opts) { Hash.new }

    specify { expect { subject }.to raise_error(KeyError) }

    context "given app_name" do
      before { opts[:app_name] = "name" }

      specify { expect { subject }.to raise_error(KeyError) }

      context "and api_key" do
        before { opts[:api_key] = "secret" }

        it { should be_instance_of(Freemle::Client) }
        its(:base_url) { should eq(Freemle::Client::BASE_URL) }
        its(:app_name) { should eq("name") }
        its(:api_key) { should eq("secret") }
      end
    end
  end

  context "configured" do
    let(:client) { Freemle::Client.new(app_name: "app", api_key: "secret") }

    describe "#customers" do
      subject { client.customers }

      it { should be_instance_of(Freemle::Resource) }
      its(:singular) { should eq(:customer) }
      its(:plural) { should eq(:customers) }
    end

    describe "#invoices" do
      subject { client.invoices }

      it { should be_instance_of(Freemle::Resource) }
      its(:singular) { should eq(:invoice) }
      its(:plural) { should eq(:invoices) }
    end
  end

  describe "::VERSION" do
    subject { Freemle::Client::VERSION }
    it { should_not be_nil }
  end
end
