# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jortt/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'jortt'
  spec.version       = Jortt::Client::VERSION
  spec.authors       = [
    'Bob Forma',
    'Michael Franken',
    'Lars Vonk',
    'Stephan van Diepen',
  ]
  spec.email         = [
    'bforma@zilverline.com',
    'mfranken@zilverline.com',
    'lvonk@zilverline.com',
    'svdiepen@zilverline.com',
  ]
  spec.summary       = 'jortt.nl REST API client'
  spec.homepage      = 'https://app.jortt.nl/api-documentatie'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exec/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'webmock', '~> 3.3'
end
