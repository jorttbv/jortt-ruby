# frozen_string_literal: true

require 'debug'
require 'rspec'
require 'rspec/its'
require 'webmock/rspec'
require 'vcr'
require 'jortt'

PRODUCTION = {
  site: 'https://api.jortt.nl',
  oauth_provider: 'https://app.jortt.nl/oauth-provider/oauth',
}.freeze
ACCEPTANCE = {
  site: 'https://api.acc.jortt.nl',
  oauth_provider: 'https://app.acc.jortt.nl/oauth-provider/oauth',
}.freeze

DOWNLOAD_LOCATION = '"download_location":"https://files.jortt.nl/invoice.pdf"'

ENV['JORTT_CLIENT_ID'] ||= 'client-id'
ENV['JORTT_CLIENT_SECRET'] ||= 'client-secret'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = {record: :once}

  # Recorded against JORTT_SITE_URL, replayed against production, so rewrite the base URL in
  # both the request line and the absolute URLs the API returns in `_links`.
  c.before_record do |i|
    {
      ENV['JORTT_SITE_URL'] => PRODUCTION[:site],
      ENV['JORTT_OAUTH_PROVIDER_URL'] => PRODUCTION[:oauth_provider],
    }.each do |recorded, replayed|
      next if recorded.nil? || recorded == replayed

      i.request.uri = i.request.uri.sub(recorded, replayed)
      i.response.body = i.response.body.gsub(recorded, replayed)
    end

    i.request.headers.delete('Authorization')
    i.response.headers.delete('Set-Cookie')

    # Served by file storage rather than the API, so the rewrite above does not reach it.
    i.response.body = i.response.body.gsub(/"download_location":"[^"]*"/, DOWNLOAD_LOCATION)

    body = begin
      JSON.parse(i.response.body)
    rescue JSON::ParserError
      nil
    end
    i.response.body = body.merge('access_token' => 'access_token').to_json if body&.key?('access_token')
  end
end

# Where the client points this run. Specs assert against these, never a hardcoded host.
def jortt_site_url
  ENV['JORTT_SITE_URL'] || PRODUCTION[:site]
end

def jortt_oauth_provider_url
  ENV['JORTT_OAUTH_PROVIDER_URL'] || PRODUCTION[:oauth_provider]
end

def jortt_client(env = 'production')
  urls = env == 'production' ? PRODUCTION : ACCEPTANCE
  ENV['JORTT_SITE_URL'] ||= urls[:site]
  ENV['JORTT_OAUTH_PROVIDER_URL'] ||= urls[:oauth_provider]

  Jortt.client(
    ENV['JORTT_CLIENT_ID'],
    ENV['JORTT_CLIENT_SECRET'],
    site: jortt_site_url,
    oauth_provider_url: jortt_oauth_provider_url,
  )
end
