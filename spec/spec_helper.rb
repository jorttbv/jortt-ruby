# frozen_string_literal: true

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
    i.response.headers.delete('Set-Cookie')
    i.request.headers.delete('Authorization')
  end
end

ENV['JORTT_CLIENT_ID'] ||= 'client-id'
ENV['JORTT_CLIENT_SECRET'] ||= 'client-secret'
