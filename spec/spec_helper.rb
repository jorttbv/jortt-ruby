require 'simplecov'
require 'rspec'
require 'rspec/its'
require 'vcr'
require 'jortt'

SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

VCR.configure do |c|
  c.cassette_library_dir = "fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { :record => :once }
end

RSpec.configure do |c|
end
