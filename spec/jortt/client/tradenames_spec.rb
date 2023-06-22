# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Tradenames, :vcr do
  let(:client) { Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }

  describe '#index' do
    subject { client.tradenames.index }

    it 'returns the tradenames' do
      expect(subject.count).to eq(2)
      expect(subject[0]).to include(
        'id' => '9a3fb97e-acb0-4367-97f7-4be733c18480',
        'company_name' => 'The best Ruby Gem',
      )
      expect(subject[1]).to include(
        'id' => 'c074a2f7-ca95-47e3-8169-9c44e5c3c85c',
        'company_name' => 'jortt-ruby gem',
      )
    end

    context "with no tradenames available" do
      it "returns an empty array" do
        expect(subject).to eq []
      end
    end
  end
end
