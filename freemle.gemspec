# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freemle/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'freemle'
  spec.version       = Freemle::Client::VERSION
  spec.authors       = ['Bob Forma', 'Steven Weller']
  spec.email         = %w(bforma@zilverline.com suweller@zilverline.com)
  spec.summary       = 'Freemle.com REST API client'
  spec.homepage      = 'https://www.freemle.com/api-documentatie'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exec/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rest-client', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'webmock', '~> 1.17'
  spec.add_development_dependency 'rubocop', '~> 0.24.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.1.0'
end
