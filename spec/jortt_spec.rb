# frozen_string_literal: true

require 'spec_helper'

describe Jortt, :vcr do
  describe '.client' do
    subject { jortt_client }
    it { should be_instance_of(described_class::Client) }
  end
end
