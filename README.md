# Jortt REST API client

[![rspec Actions Status](https://github.com/jorttbv/jortt-ruby/workflows/rspec/badge.svg)](https://github.com/jorttbv/jortt-ruby/actions)

A Ruby interface to the [Jortt](https://www.jortt.nl/) REST API.

Check https://developer.jortt.nl/ for more info.

> THIS VERSION IS FOR THE NEW OAUTH API. STILL ON THE LEGACY API? USE VERSION 4.x OF THIS GEM: [CLICK HERE](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0)

## Upgrading to 7.0

Every request now goes to the `/v3` API. The unversioned endpoints this gem previously used
are being discontinued along with `/v1`.

Most resources moved path only, so their request and response bodies are
unchanged. Two of them changed shape and need code changes on your side:

**Invoice line items** (`invoices.create`, and the line items returned by
`invoices.index` / `invoices.show`):

| before | after |
| --- | --- |
| `number_of_units: "4"` | `quantity: "4"` |
| `amount_per_unit: { value:, currency: }` | `amount: { amount:, currency: }` |
| `vat_percentage: "21.0"` | `vat: { value: "0.21", category: nil }` |

`description`, `quantity`, `amount` and `vat` are all required, and `vat.value`
is a fraction rather than a percentage. On responses, `total_amount_excl_vat` is
now `total_amount_ex_vat`.

**Customer VAT percentages** (`customers.vat_percentages`):

```ruby
# before
{ "id" => "...", "vat_percentages" => { "standard_rate" => "21.0", "reduced_rate" => ["9.0", "0.0"] } }

# after
{ "id" => "...", "vats" => [{ "value" => "0.21", "category" => nil }, ...] }
```

The `vat_percentages` hash of named rates becomes a `vats` array of objects. As
with invoice line items, `value` is a fraction rather than a percentage.

## Usage examples

To create a jortt client using client credentials grant type:
```ruby
jortt = Jortt.client('<your-client-id>', '<your-client-secret>')
```

To create a Jortt client using authorization code grant type:
```ruby
jortt = Jortt.client(
  '<your-client-id>', 
  '<your-client-secret>', 
  scope: "invoices:read customers:read", 
  access_token: "access-token",
  refresh_token: "refresh-token",
  expires_at: "1657896798"
)
```

You can use the [oauth2 gem](https://github.com/oauth-xx/oauth2) to request an access and refresh token.

### Customers

All customers (`jortt.customers.index`) returns an enumerator that pages through every customer:
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
Get invoices by ID (`jortt.invoices.show('934d59dd-76f6-4716-9e0f-82a618e1be21')`) returns:
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
      quantity: "3.14",
      amount: {
        amount: "365.00",
        currency: "EUR"
      },
      vat: {
        value: "0.21",
        category: nil
      },
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
