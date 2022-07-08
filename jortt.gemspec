# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jortt/client/version'

Gem::Specification.new do |spec|
  spec.name = 'jortt'
  spec.version = Jortt::Client::VERSION
  spec.authors = [
    'Bob Forma',
    'Michael Franken',
    'Lars Vonk',
    'Stephan van Diepen',
  ]
  spec.email = [
    'bforma@zilverline.com',
    'mfranken@zilverline.com',
    'lvonk@zilverline.com',
    'stephan@vandiepen.info',
  ]
  spec.required_ruby_version = '>= 2.7'
  spec.summary = 'jortt.nl REST API client'
  spec.homepage = 'https://app.jortt.nl/api-documentatie'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^exec/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oauth2', '~> 1.4.4'
  spec.add_runtime_dependency 'rest-client', ['>= 2.0', '< 2.2']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop', '< 1.21'
  spec.add_development_dependency 'vcr', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.3'
end
