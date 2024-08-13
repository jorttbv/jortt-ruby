# frozen_string_literal: true

require 'spec_helper'

describe Jortt::Client::Error, :vcr do
  let(:client) { jortt_client }

  it 'raises Jortt::Client::JorttError' do
    expect do
      client.customers.show(999)
    end.to raise_error do |error|
      expect(error).to be_a(Jortt::Client::Error)
      expect(error).to be_an_instance_of(Jortt::Client::JorttError)
      expect(error).to have_attributes(
        code: 422,
        key: 'params.invalid',
        message: 'The parameters are invalid (either missing, not of the correct type or incorrect format).',
        details: [{'key' => 'is_invalid','param' => 'customer_id','message' => 'is invalid'}],
      )
    end
  end

  context '502 Bad Gateway' do
    it 'raises ServerError' do
      expect do
        client.customers.show('1aa9cd93-aa14-4184-ba01-1fa2776d2e2d')
      end.to raise_error do |error|
        expect(error).to be_a(Jortt::Client::Error)
        expect(error).to be_an_instance_of(Jortt::Client::ServerError)
        expect(error).to have_attributes(
          status: 502,
          message: 'Bad Gateway',
          body: "<html>\n<head><title>502 Bad Gateway</title></head>\n<body>\n<center><h1>502 Bad Gateway</h1></center>\n</body>\n</html>\n",
        )
      end
    end
  end
end
