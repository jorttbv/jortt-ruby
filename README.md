# Freemle REST API client

[![Build Status](https://travis-ci.org/freemle/freemle-ruby.svg)](https://travis-ci.org/freemle/freemle-ruby)
[![Coverage Status](https://coveralls.io/repos/freemle/freemle-ruby/badge.png)](https://coveralls.io/r/freemle/freemle-ruby)
[![Code Climate](https://codeclimate.com/github/freemle/freemle-ruby.png)](https://codeclimate.com/github/freemle/freemle-ruby)

A Ruby interface to the [Freemle](https://www.freemle.com/) REST API.

## Usage

To create a freemle client:
```ruby
freemle = Freemle::Client.new(
  app_name: "application-name-as-chosen-on-freemle.com",
  api_key: "api-key-as-provided-by-freemle.com"
)
```

### Customers

Accessing customers:
```ruby
freemle.customers.search('Freemle')
[{
  company_name: 'Freemle',
  address: {
    street: "Cruquiusweg 109 F",
    postal_code: "1019 AG",
    city: "Amsterdam",
    country_code: "NL"
  }
},
  company_name: 'Elmeerf',
  address: {
    street: "Freemleweg",
    ...
  }
}]
```

Adding customers:
```ruby
customers.create(
  company_name: "Zilverline B.V.",
  address: {
    street: "Cruquiusweg 109 F",
    postal_code: "1019 AG",
    city: "Amsterdam",
    country_code: "NL"
  }
)
```

### Invoices

Adding invoices:
```ruby
invoices.create(
  customer_id: "123456789", # Optional
  delivery_period: "31-12-1234", # Optional
  reference: "my-reference", # Optional
  line_items: [
    {vat: 21, amount: 1359.50, quantity: 1, description: "Scrum Training"}
  ]
)
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
