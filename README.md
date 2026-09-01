# Jortt REST API client

[![rspec Actions Status](https://github.com/jorttbv/jortt-ruby/workflows/rspec/badge.svg)](https://github.com/jorttbv/jortt-ruby/actions)

A Ruby interface to the [Jortt](https://www.jortt.nl/) REST API.

See https://developer.jortt.nl/ for the API documentation.

> **Note**
> This version targets the OAuth API. If you are still on the legacy API, use
> [version 4.2.0](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0) of this gem.

> **Upgrading from 6.x?** Version 7.0 moves every request to the `/v3` API and renames several
> fields. See [UPGRADING.md](UPGRADING.md) for the migration guide, and
> [CHANGELOG.md](CHANGELOG.md) for the full list of changes.

## Installation

Add the gem to your `Gemfile`:

```ruby
gem 'jortt'
```

Then run `bundle install`. Or install it directly:

```
gem install jortt
```

The gem requires Ruby 2.7 or newer.

## Getting started

Create a client with the client credentials grant type:

```ruby
jortt = Jortt.client('<your-client-id>', '<your-client-secret>')
```

Or with the authorization code grant type:

```ruby
jortt = Jortt.client(
  '<your-client-id>',
  '<your-client-secret>',
  scope: 'invoices:read customers:read',
  access_token: '<access-token>',
  refresh_token: '<refresh-token>',
  expires_at: 1657896798
)
```

You can use the [oauth2 gem](https://github.com/oauth-xx/oauth2) to request an access and
refresh token.

### Scopes

Without a `scope:` option the client requests `Jortt::Client::DEFAULT_SCOPE`:

```
invoices:read invoices:write customers:read customers:write organizations:read expenses:read
```

Writing expenses needs `expenses:write`, which the default does not include. Register the scope
with Jortt first — Jortt rejects a token request for a scope your application is not registered
for — and then request it alongside the defaults:

```ruby
jortt = Jortt.client(
  '<your-client-id>',
  '<your-client-secret>',
  scope: "#{Jortt::Client::DEFAULT_SCOPE} expenses:write"
)
```

## Available operations

| Resource | Operations |
| --- | --- |
| `jortt.customers` | `index(query:)`, `show(id)`, `create(payload)`, `update(id, payload)`, `delete(id)`, `direct_debit_mandate(id)`, `vats(id)` |
| `jortt.invoices` | `index(query:, invoice_status:)`, `show(id)`, `create(payload)`, `credit(id, payload)`, `download(id)` |
| `jortt.expenses` | `index(vat_date_from:, vat_date_till:, delivery_date_from:, delivery_date_till:, expense_type:)`, `show(id)`, `create(payload)`, `update(id, payload)`, `attach_receipt(id, payload)` |
| `jortt.ledger_accounts` | `index` |
| `jortt.organizations` | `me` |
| `jortt.tradenames` | `index` |

`customers.index`, `invoices.index` and `expenses.index` are paginated, and return an
enumerator that fetches pages on demand. Every other method returns the parsed response body,
except `customers.delete`, which returns `true`.

## Usage examples

### Customers

`customers.index` returns an enumerator that fetches each page of customers as you read it.
Call `.to_a`, or iterate it, to get the records. Each iteration starts again at the first page,
so keep the array from `.to_a` if you read the records more than once.

```ruby
jortt.customers.index.to_a
# => [{
#      "id" => "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
#      "is_private" => true,
#      "customer_name" => "Jortt",
#      "address_street" => "Rozengracht 75a",
#      ...
#    }]

jortt.customers.index(query: 'Jortt').each { |customer| puts customer['customer_name'] }
```

`query` searches for customers matching the text, and needs three characters or more.

Creating a customer:

```ruby
jortt.customers.create(
  is_private: true,
  customer_name: 'Jortt',
  address_street: 'Rozengracht 75a',
  address_postal_code: '1016LR',
  address_city: 'Amsterdam'
)
```

The VAT rates valid for a customer:

```ruby
jortt.customers.vats('9afcd96e-caf8-40a1-96c9-1af16d0bc804')
# => {
#      "id" => "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
#      "vats" => [{"value" => "0.21", "category" => nil}, ...]
#    }
```

Each `value` is a fraction, not a percentage: `"0.21"` means 21%.

### Invoices

```ruby
jortt.invoices.show('934d59dd-76f6-4716-9e0f-82a618e1be21')
# => {
#      "id" => "934d59dd-76f6-4716-9e0f-82a618e1be21",
#      "invoice_status" => "sent",
#      "invoice_number" => "202009-226",
#      "invoice_date" => "2020-09-24",
#      "invoice_due_date" => "2020-10-24",
#      "invoice_total" => {"amount" => "1996.00", "currency" => "EUR"},
#      "invoice_total_incl_vat" => {"amount" => "2415.16", "currency" => "EUR"},
#      "invoice_due_amount" => {"amount" => "2415.16", "currency" => "EUR"},
#      "customer_id" => "e1c5e15b-e34e-423e-a291-4ed43226a190",
#      "customer_company_name" => "Zilverline B.V.",
#      "customer_attn" => nil,
#      "customer_address_street" => "Cruquisweg 109F",
#      "customer_address_city" => "Amsterdam",
#      "customer_address_postal_code" => "1111SX",
#      "customer_address_country_code" => "NL",
#      "customer_address_country_name" => "Nederland",
#      "line_items" => [
#        {
#          "description" => "Your product",
#          "quantity" => "4",
#          "amount" => {"amount" => "499.00", "currency" => "EUR"},
#          "vat" => {"value" => "0.21", "category" => nil},
#          "total_amount_ex_vat" => {"amount" => "499.00", "currency" => "EUR"},
#          "ledger_account_id" => "05ba2a61-a0cc-4736-9000-89fb361e85c8"
#        }
#      ],
#      ...
#    }
```

The customer details are flat fields with a `customer_` prefix — there is no nested `recipient`
object.

Searching invoices, optionally filtered by status (`sent`, `draft`, `unpaid`, `late` or
`paid`):

```ruby
jortt.invoices.index(query: '202001-002', invoice_status: 'draft').to_a
# => [{
#      "id" => "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
#      "invoice_status" => "draft",
#      "customer_id" => "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
#      "invoice_number" => "202001-002",
#      "invoice_date" => "2020-02-23",
#      ...
#    }]
```

Creating an invoice. Each line item needs `description`, `quantity`, `amount` and `vat`, and
`vat.value` is a fraction rather than a percentage:

```ruby
jortt.invoices.create(
  customer_id: 'f8fd3e4e-da1c-43a7-892f-1410ac13e38a',
  invoice_date: '2020-02-23',
  delivery_period: '2020-02-01',
  payment_term: 14,
  net_amounts: true,
  send_method: 'email',
  introduction: 'example',
  remarks: 'example',
  payment_method: 'pay_later',
  line_items: [
    {
      description: 'this is a description example',
      quantity: '3.14',
      amount: {amount: '365.00', currency: 'EUR'},
      vat: {value: '0.21', category: nil},
      ledger_account_id: 'f8fd3e4e-da1c-43a7-892f-1410ac13e38a'
    }
  ],
  reference: '123'
)
```

Crediting an invoice, and fetching a PDF download link:

```ruby
jortt.invoices.credit('934d59dd-76f6-4716-9e0f-82a618e1be21', send_method: 'email')
jortt.invoices.download('934d59dd-76f6-4716-9e0f-82a618e1be21')
```

### Expenses

`expenses.index` returns an enumerator that fetches each page of expenses as you read it. All
of its filters are optional. Format `vat_date_from`, `vat_date_till`, `delivery_date_from` and
`delivery_date_till` as `YYYY-MM-DD`, and set `expense_type` to `cost`, `income` or `balance`:

```ruby
jortt.expenses.index(vat_date_from: '2026-01-01', vat_date_till: '2026-03-31').to_a
jortt.expenses.show('9afcd96e-caf8-40a1-96c9-1af16d0bc804')
```

Creating an expense requires `description`, `ledger_account_id`, `expense_type`, `vat_date`,
`delivery_period`, `vat_type` and `raw_total_amount`. `vat_type` is one of the `btw_type_*`
values listed in the [API documentation](https://developer.jortt.nl/#tag-v3-expenses):

```ruby
jortt.expenses.create(
  description: 'Office equipment',
  ledger_account_id: '05ba2a61-a0cc-4736-9000-89fb361e85c8',
  expense_type: 'cost',
  vat_date: '2026-01-15',
  delivery_period: '2026-01-01',
  vat_type: 'btw_type_leverancier_uit_nl',
  raw_total_amount: {amount: '121.00', currency: 'EUR'},
  vat_line_items: [
    {
      vat: {value: '0.21', category: nil},
      vat_amount: {amount: '21.00', currency: 'EUR'}
    }
  ]
)
```

`expenses.update` takes the same fields, and requires the same ones, so send the complete
expense rather than only what changed:

```ruby
jortt.expenses.update('9afcd96e-caf8-40a1-96c9-1af16d0bc804', payload)
```

`expenses.attach_receipt` attaches a file to an expense. Upload the file through
`POST /v3/files/attachment_upload` first, then pass the identifier it returns:

```ruby
jortt.expenses.attach_receipt(
  '9afcd96e-caf8-40a1-96c9-1af16d0bc804',
  receipt_id: '1aa9cd93-aa14-4184-ba01-1fa2776d2e2d'
)
```

Creating, updating and attaching receipts all need the `expenses:write` scope. See
[Scopes](#scopes).

### Ledger accounts, organizations and tradenames

```ruby
jortt.ledger_accounts.index  # ledger accounts available to invoice line items
jortt.organizations.me       # the organization the credentials belong to
jortt.tradenames.index       # the tradenames of that organization
```

## Error handling

The gem raises `Jortt::Client::Error` for any failed request. Two subclasses carry the details:

- `Jortt::Client::JorttError` for a `4xx` response, with `code`, `key`, `message` and `details`.
- `Jortt::Client::ServerError` for a `5xx` response, with `status`, `message` and `body`.

```ruby
begin
  jortt.invoices.create(payload)
rescue Jortt::Client::JorttError => e
  warn "#{e.key}: #{e.message}"
  warn e.details.inspect
rescue Jortt::Client::ServerError => e
  warn "Jortt is unavailable (#{e.status})"
end
```

Rescue `Jortt::Client::Error` to catch both.

## Development

### Running tests

`bundle install` and then `rake spec` or `rspec spec`.

### Building the gem

`rake build` and then `rake install` to test it locally (`irb` followed
by `require 'jortt/client'` and do your stuff).

### Releasing the gem

Make a fix, commit and push. Make sure the build is green. Then bump the
version (edit `lib/jortt/client/version.rb`) and move the unreleased entries in
[CHANGELOG.md](CHANGELOG.md) under the new version heading. Add a section to
[UPGRADING.md](UPGRADING.md) as well if the release breaks anything. Now `rake release` and
follow the instructions (you need a rubygems.org account and permissions ;-)).

Otherwise `gem build jortt.gemspec` and `gem push jortt-[version].gem`.
