require 'spec_helper'

describe Freemle do
  describe '.client' do
    subject { described_class.client(app_name: 'name', api_key: 'secret') }
    it { should be_instance_of(described_class::Client) }
  end
end
