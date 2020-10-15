# Jortt REST API client

[![Inline docs](
http://inch-ci.org/github/jorttbv/jortt-ruby.svg?branch=master&style=flat
)](http://inch-ci.org/github/jorttbv/jortt-ruby)
[![Code Climate](
http://img.shields.io/codeclimate/github/jorttbv/jortt-ruby.svg?style=flat
)](https://codeclimate.com/github/jorttbv/jortt-ruby)
[![Code Coverage](
https://codecov.io/github/jorttbv/jortt-ruby/coverage.svg?branch=master
)](https://codecov.io/github/jorttbv/jortt-ruby?branch=master)
[![Build Status](
http://img.shields.io/travis/jorttbv/jortt-ruby.svg?style=flat
)](https://travis-ci.org/jorttbv/jortt-ruby)

A Ruby interface to the [Jortt](https://www.jortt.nl/) REST API.

Check https://developer.jortt.nl/ for more info.

> THIS VERSION IS FOR THE NEW OAUTH API. STILL ON THE LEGACY API? USE VERSION 4.x OF THIS GEM: [CLICK HERE](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0)

> THIS VERSION ONLY WORKS FOR CLIENT CREDENTIALS CURRENTLY.

## Usage examples

To create a jortt client:
```ruby
jortt = Jortt.client('<your-client-id>', '<your-client-secret>')
```

### Customers

All customers (`jortt.customers.index(page: 2)`) returns:
```ruby
[{
  "id": "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  "is_private": true,
  "customer_name": "Jortt",
  "address_street": "Rozengracht 75a",
  ...
}]
```

Adding customers:
```ruby
jortt.customers.create(
  "is_private": true,
  "customer_name": "Jortt",
  ...
)
```

### Invoices
Get invoices by ID (`jortt.invoices.get('934d59dd-76f6-4716-9e0f-82a618e1be21')`) returns:
```ruby
{
  "invoice_id": "934d59dd-76f6-4716-9e0f-82a618e1be21",
  "recipient": {
    "company_name": "Zilverline B.V.",
    "attn": null,
    "address": {
      "street": "Cruquisweg 109F",
      "city": "Amsterdam",
      "postal_code": "1111SX",
      "country": {
        "code": "NL",
        "name": "Nederland"
      }
    },
    "email": "ben@jortt.nl",
    "customer_id": "e1c5e15b-e34e-423e-a291-4ed43226a190",
    "extra_information": null,
    ...
  }
  ...
}
```


Searching invoices (`jortt.invoices.index(query: '202001-002')`) returns:
```ruby
[{
  "id": "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  "invoice_status": "draft",
  "customer_id": "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  "invoice_number": "202001-002",
  "invoice_date": "2020-02-23",
  ...
}]

```


Adding invoices:
```ruby
jortt.invoices.create(
  customer_id: "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  invoice_date: "2020-02-23",
  delivery_period: "2020-02-01",
  payment_term: 14,
  net_amounts: true,
  send_method: "email",
  introduction: "example",
  remarks: "example",
  payment_method: "pay_later",
  line_items: [
    {
      description: "this is a description example",
      units: 3.14,
      amount_per_unit: {
        value: "365.00",
        currency: "EUR"
      },
      vat: 21,
      ledger_account_id: "f8fd3e4e-da1c-43a7-892f-1410ac13e38a"
    }
  ],
  reference: "123"
)
```

## Development

### Running tests

`bundle install` and then `rake spec` or `rspec spec`.

### Building the gem

`rake build` and then `rake install` to test it locally (`irb` followed
by `require 'jortt/client'` and do your stuff).

### Releasing the gem

Make a fix, commit and push. Make sure the build is green. Then bump the
version (edit `lib/jortt/client/version.rb`). Now `rake release` and follow
the instructions (you need a rubygems.org account and permissions ;-)).

Otherwise `gem build jortt.gemspec` and `gem push jortt-[version].gem`.
