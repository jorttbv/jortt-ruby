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

## Usage

To create a jortt client:
```ruby
jortt = Jortt.client(
  app_name: "application-name-as-chosen-on-jortt.nl",
  api_key: "api-key-as-provided-by-jortt.nl"
)
```

### Customers

Searching customers (`jortt.customers.search('Jortt')`) returns:
```ruby
[{
  company_name: 'Jortt',
  address: {
    street: "Transistorstraat 71C",
    postal_code: "1322 CK",
    city: "Almere",
    country_code: "NL"
  }
},
  company_name: 'ttroj',
  address: {
    street: "Jorttweg",
    ...
  }
}]
```

Adding customers:
```ruby
jortt.customers.create(
  company_name: "Jortt B.V.",
  attn: "Vibiemme", # Optional
  extra_information: "The best cofee maker!", # Optional
  address: {
    street: "Transistorstraat 71C",
    postal_code: "1322 CK",
    city: "Almere",
    country_code: "NL"
  }
)
```

### Invoices
Searching invoices (`jortt.invoices.search('201606-012')`) returns:
```ruby
[
  {
    "invoice_id": "934d59dd-76f6-4716-9e0f-82a618e1be21",
    "recipient": {
      "company_name": "Zilverine B.V.",
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
      "shift_vat": null,
      "vat_number": null,
      "payment_term": 30
    },
    "recipient_in_eu": true,
    "organization": {
      "company_name": "Jortt BV",
      "company_name_line_2": null,
      "address": {
        "street": "Straat 1",
        "city": "Amsterdam",
        "postal_code": "1000 AA",
        "country": {
          "code": "NL",
          "name": "Nederland"
        }
      },
      "phonenumber": null,
      "bank_information": {
        "bic": "RABONL2U",
        "iban": "NL50RABO0150000001",
        "in_the_name_of": "Jortt B.V.",
        "description": null
      },
      "coc_number": "unique number",
      "vat_number": "NL821898279B01",
      "profession": null,
      "healthcare_data": null,
      "free_of_vat": false,
      "finance_email": "Jortt BV <compleet@jortt.nl>"
    },
    "line_items": [
      {
        "description": "Scrum",
        "vat": "0.21",
        "amount": "-100.0",
        "total_amount_ex_vat": "-100.0",
        "currency": "EUR",
        "quantity": "1.0"
      }
    ],
    "invoice_currency": null,
    "invoice_total": "-100.0",
    "invoice_total_incl_vat": "-121.0",
    "invoice_number": "201607-011",
    "invoice_status": "paid",
    "invoice_due_date": "2016-08-06",
    "invoice_date": "2016-07-07",
    "invoice_delivery_period": "2016-07-01",
    "invoice_remarks": null,
    "invoice_language": "nl",
    "invoice_reference": null
  }
]

```


Adding invoices:
```ruby
jortt.invoices.create(
  customer_id: "123456789", # Optional
  delivery_period: "31-12-1234", # Optional
  reference: "my-reference", # Optional
  line_items: [
    {vat: 21, amount: 1359.50, quantity: 1, description: "Scrum Training"}
  ]
)
```

Sending invoices:
```ruby
jortt.invoice(:invoice_id).send_invoice(
  mail_data: {
    to: 'ben@jortt.nl', # optional
    subject: 'Thank you for your assignment', # optional
    body: 'I hereby send you the invoice', # optional
  },
  invoice_date: Date.today, # optional
  payment_term: 7, # optional
  language: 'nl', # optional
  send_method: 'email', # optional
)
```


## Documentation

Check https://app.jortt.nl/api-documentatie for more info.

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
