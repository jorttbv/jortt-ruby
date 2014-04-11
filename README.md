# Freemle REST API client

[![Build Status](https://travis-ci.org/freemle/freemle-ruby.svg)](https://travis-ci.org/freemle/freemle-ruby)
[![Code Climate](https://codeclimate.com/github/freemle/freemle-ruby.png)](https://codeclimate.com/github/freemle/freemle-ruby)

A Ruby interface to the [Freemle](https://www.freemle.com/) REST API.

## Usage

```
Freemle::Client.base_url = "https://www.freemle.com/api"
Freemle::Client.app_name = "your_application_name"
Freemle::Client.api_key = "your_api_key"
```

## Documentation

Check https://www.freemle.com/api-documentatie for more info.

## Development

### Running tests

`bundle install` and then `rake spec` or `rspec spec`.

### Building the gem

`rake build` and then `rake install` to test it locally (`irb` followed
by `require 'freemle/client'` and do your stuff).

### Releasing the gem

Make a fix, commit and push. Make sure the build is green. Then bump the
version (edit `lib/freemle/client/version.rb`). Now `rake release` and follow
the instructions (you need a rubygems.org account and permissions ;-)).
