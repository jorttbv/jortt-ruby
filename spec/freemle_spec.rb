require 'spec_helper'

describe Freemle do
  describe '.client' do
    subject { Freemle.client(app_name: 'name', api_key: 'secret') }
    it { should be_instance_of(Freemle::Client) }
  end
end
