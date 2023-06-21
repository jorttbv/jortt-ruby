# frozen_string_literal: true

require 'debug'
require 'rspec'
require 'rspec/its'
require 'webmock/rspec'
require 'vcr'
require 'jortt'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {record: :once}

  c.before_record do |i|
    i.request.headers.delete('Authorization')
    i.response.headers.delete('Set-Cookie')

    if !i.response.body.empty? && JSON.parse(i.response.body)['access_token']
      i.response.body = JSON.parse(i.response.body).tap { |b| b['access_token'] = 'access_token' }.to_json
    end
  end
end

ENV['JORTT_CLIENT_ID'] ||= 'client-id'
ENV['JORTT_CLIENT_SECRET'] ||= 'client-secret'

def jortt_client(env = 'production')
  if env == 'production'
    ENV['JORTT_SITE_URL'] ||= 'https://api.jortt.nl'
    ENV['JORTT_OAUTH_PROVIDER_URL'] ||= 'https://app.jortt.nl/oauth-provider/oauth'
  else
    ENV['JORTT_SITE_URL'] ||= 'https://api.acc.jortt.nl'
    ENV['JORTT_OAUTH_PROVIDER_URL'] ||= 'https://app.acc.jortt.nl/oauth-provider/oauth'
  end

  Jortt.client(ENV['JORTT_CLIENT_ID'], ENV['JORTT_CLIENT_SECRET'], site: ENV['JORTT_SITE_URL'], oauth_provider_url: ENV['JORTT_OAUTH_PROVIDER_URL'])
end
