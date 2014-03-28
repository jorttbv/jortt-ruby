# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freemle/client/version'

Gem::Specification.new do |spec|
  spec.name          = "freemle-client"
  spec.version       = Freemle::Client::VERSION
  spec.authors       = ["Bob Forma"]
  spec.email         = ["bforma@zilverline.com"]
  spec.summary       = %q{Freemle.com REST API client}
  spec.homepage      = "https://www.freemle.com/api-documentatie"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"

  spec.add_dependency "activesupport"
  spec.add_dependency "httpclient"
end
