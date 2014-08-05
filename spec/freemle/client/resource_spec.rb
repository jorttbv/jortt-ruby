require 'spec_helper'

describe Freemle::Client::Resource do
  let(:resource) do
    described_class.new(
      double('client', base_url: 'foo', app_name: 'app', api_key: 'secret'),
      :person,
      :people,
    )
  end

  describe '#search' do
    subject { resource.search('terms') }
    before do
      stub_request(:get, 'http://app:secret@foo/people?query=terms').
        to_return(status: 200, body: '{"people": []}')
    end
    it { should eq('people' => []) }
  end

  describe '#create' do
    subject { resource.create(foo: :bar) }
    before do
      stub_request(:post, 'http://app:secret@foo/people').
        with(body: '{"person":{"foo":"bar"}}').
        to_return(status: 201, body: '{"person_id": "123"}')
    end
    it { should eq('person_id' => '123') }
  end
end
