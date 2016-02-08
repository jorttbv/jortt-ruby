require 'simplecov'

SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'rspec'
require 'rspec/its'
require 'webmock/rspec'

require 'jortt'
