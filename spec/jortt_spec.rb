require 'spec_helper'

describe Jortt, :vcr do
  describe '.client' do
    subject { described_class.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET']) }
    it { should be_instance_of(described_class::Client) }
  end
end
