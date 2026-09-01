# Jortt REST API client

[![rspec Actions Status](https://github.com/jorttbv/jortt-ruby/workflows/rspec/badge.svg)](https://github.com/jorttbv/jortt-ruby/actions)

A Ruby interface to the [Jortt](https://www.jortt.nl/) REST API.

Check https://developer.jortt.nl/ for more info.

> THIS VERSION IS FOR THE NEW OAUTH API. STILL ON THE LEGACY API? USE VERSION 4.x OF THIS GEM: [CLICK HERE](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0)

## Upgrading to 7.0

Every request now goes to the `/v3` API endpoint. Jortt discontinues the unversioned and `/v1`
endpoints that this gem previously used in 5.x and 6.x.

The new paths are internal to this gem, so your code does not change, however there are three data format
changes below which might require attention. If a request uses one of these old field name, the API rejects the
request and this gem raises an error. A read of one of these old keys will be silent: i.e. the key is absent, so the
read returns `nil`. It is advised to search your code for the old names and make the appropriate updates.

### 1. Money objects use `amount` instead of `value`

Each amount uses a new key in requests and in responses:

| before 7.0 | 7.0 |
| --- | --- |
| `{value: "12.34", currency: "EUR"}` | `{amount: "12.34", currency: "EUR"}` |

On an invoice, this change applies to `invoice_total`, `invoice_total_incl_vat`,
`invoice_due_amount` and each line item amount:

```ruby
# before 7.0
invoice.dig('invoice_due_amount', 'value')

# 7.0
invoice.dig('invoice_due_amount', 'amount')
```

### 2. Invoice line items

These changes apply to `invoices.create` and line items in the responses from `invoices.index` and `invoices.show`:

| before 7.0 | 7.0 |
| --- | --- |
| `units: 4` | `quantity: "4"` |
| `amount_per_unit: {value:, currency:}` | `amount: {amount:, currency:}` |
| `vat: 21.0` | `vat: {value: "0.21", category: nil}` |
| `total_amount_excl_vat: {value:, currency:}` | `total_amount_ex_vat: {amount:, currency:}` |

- `total_amount_ex_vat` is in responses only. In a line item, each number is a string.

- `vat` requires care. The value is now a fraction, and not a percentage:

| percentage (before 7.0) | fraction (7.0) |
| --- | --- |
| `21.0` | `"0.21"` |
| `9.0` | `"0.09"` |
| `0.0` | `"0.00"` |

The fields `description`, `quantity`, `amount` and `vat` are required fields when creating an invoice.

### 3. Customer VAT percentages

| before 7.0 | 7.0 |
| --- | --- |
| `customers.vat_percentages` | `customers.vats` |
| `vat_percentages: {standard_rate:, reduced_rate:}` | `vats: [{value:, category:}]` |

The old method name is still available however as a deprecated alias.

```ruby
# before 7.0
{"id" => "...", "vat_percentages" => {"standard_rate" => "21.0", "reduced_rate" => ["9.0", "0.0"]}}

# 7.0
{"id" => "...", "vats" => [{"value" => "0.21", "category" => nil}, ...]}
```

`value` requires care. It is now a fraction, and not a percentage.

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

`jortt.customers.index` returns a lazy enumerator. The enumerator requests each page of
customers in turn. Call `.to_a`, or iterate the enumerator, to read the records. Each iteration
starts again at the first page, so assign the array from `.to_a` if you read the records twice.

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
  "id" => "934d59dd-76f6-4716-9e0f-82a618e1be21",
  "invoice_status" => "sent",
  "invoice_number" => "202009-226",
  "invoice_date" => "2020-09-24",
  "invoice_due_date" => "2020-10-24",
  "invoice_total" => {"amount" => "1996.00", "currency" => "EUR"},
  "invoice_total_incl_vat" => {"amount" => "2415.16", "currency" => "EUR"},
  "invoice_due_amount" => {"amount" => "2415.16", "currency" => "EUR"},
  "customer_id" => "e1c5e15b-e34e-423e-a291-4ed43226a190",
  "customer_company_name" => "Zilverline B.V.",
  "customer_attn" => nil,
  "customer_address_street" => "Cruquisweg 109F",
  "customer_address_city" => "Amsterdam",
  "customer_address_postal_code" => "1111SX",
  "customer_address_country_code" => "NL",
  "customer_address_country_name" => "Nederland",
  "line_items" => [
    {
      "description" => "Your product",
      "quantity" => "4",
      "amount" => {"amount" => "499.00", "currency" => "EUR"},
      "vat" => {"value" => "0.21", "category" => nil},
      "total_amount_ex_vat" => {"amount" => "499.00", "currency" => "EUR"},
      "ledger_account_id" => "05ba2a61-a0cc-4736-9000-89fb361e85c8"
    }
  ],
  ...
}
```

The customer details are flat fields with a `customer_` prefix.

Searching invoices (`jortt.invoices.index(query: '202001-002')`) returns:
```ruby
[{
  "id" => "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  "invoice_status" => "draft",
  "customer_id" => "f8fd3e4e-da1c-43a7-892f-1410ac13e38a",
  "invoice_number" => "202001-002",
  "invoice_date" => "2020-02-23",
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

### Expenses

`jortt.expenses.index` returns an enumerator. The enumerator requests each page of expenses in
turn. These filters are optional: `vat_date_from`, `vat_date_till`, `delivery_date_from`,
`delivery_date_till` and `expense_type`. The `expense_type` filter accepts `cost`, `income` or
`balance`. Give each date in `YYYY-MM-DD` format.

```ruby
jortt.expenses.index(vat_date_from: '2026-01-01', vat_date_till: '2026-03-31')
jortt.expenses.show('9afcd96e-caf8-40a1-96c9-1af16d0bc804')
```

`jortt.expenses.create`, `.update` and `.attach_receipt` need the `expenses:write` scope, which
the default scope does **not** include. First register the scope with Jortt, because Jortt
rejects a token request for a scope that it does not hold for your application. Then give the
scope to the client:

```ruby
jortt = Jortt.client(id, secret, scope: "#{Jortt::Client::DEFAULT_SCOPE} expenses:write")
```

When you create an expense, you must give `description`, `ledger_account_id`, `expense_type`,
`vat_date`, `delivery_period`, `vat_type` and `raw_total_amount`:

```ruby
jortt.expenses.create(
  description: "Office equipment",
  ledger_account_id: "05ba2a61-a0cc-4736-9000-89fb361e85c8",
  expense_type: "cost",
  vat_date: "2026-01-15",
  delivery_period: "2026-01-01",
  vat_type: "btw_type_leverancier_uit_nl",
  raw_total_amount: {amount: "121.00", currency: "EUR"},
  vat_line_items: [
    {
      vat: {value: "0.21", category: nil},
      vat_amount: {amount: "21.00", currency: "EUR"}
    }
  ]
)
```

`jortt.expenses.update(id, payload)` takes the same fields, and the same fields are required.
Send the complete expense, and not only the fields that changed.

`jortt.expenses.attach_receipt(id, receipt_id: '...')` attaches a file to an expense. First
upload the file with `POST /v3/files/attachment_upload`.

### Other resources

```ruby
jortt.ledger_accounts.index  # the ledger accounts for invoice line items
jortt.organizations.me       # the organization that owns the credentials
jortt.tradenames.index       # the tradenames of the organization
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
