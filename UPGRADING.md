# Upgrading

## 6.x to 7.0

Every request now goes to the `/v3` API. Jortt is discontinuing the unversioned and `/v1`
endpoints that 5.x and 6.x used.

The new paths are internal to the gem, so the calls you already make keep working. Three data
formats changed, and those do need attention. Sending an old field name fails loudly — the API
rejects the request and the gem raises `Jortt::Client::JorttError`. Reading an old key fails
silently: the key is absent, so you get `nil`. Search your code for the old names before
upgrading.

### At a glance

| | 6.x | 7.0 |
| --- | --- | --- |
| Money object | `{value: "12.34", currency: "EUR"}` | `{amount: "12.34", currency: "EUR"}` |
| Line item units | `units: 4` | `quantity: "4"` |
| Line item unit price | `amount_per_unit: {value:, currency:}` | `amount: {amount:, currency:}` |
| Line item VAT | `vat: 21.0` | `vat: {value: "0.21", category: nil}` |
| Line item total (response) | `total_amount_excl_vat` | `total_amount_ex_vat` |
| Invoice identifier | `invoice_id` | `id` |
| Invoice customer | nested `recipient` object | flat `customer_*` fields |
| Customer VAT rates | `customers.vat_percentages` | `customers.vats` |
| Expense free-text search | `expenses.index(query:)` | removed |

### 1. Money objects use `amount` instead of `value`

Every amount, in both requests and responses, keys on `amount`:

```ruby
# 6.x
invoice.dig('invoice_due_amount', 'value')

# 7.0
invoice.dig('invoice_due_amount', 'amount')
```

On an invoice this applies to `invoice_total`, `invoice_total_incl_vat`, `invoice_due_amount`
and every line item amount.

Note the asymmetry, because it is easy to get wrong: **money** objects key on `amount`, but
**VAT** objects key on `value`. A line item therefore reads
`{amount: {amount: "499.00", currency: "EUR"}, vat: {value: "0.21", category: nil}}`.

### 2. VAT is a fraction, not a percentage

Wherever a VAT rate appears — invoice line items, expense VAT line items, customer VAT rates —
it is now an object whose `value` is a string fraction:

| percentage (6.x) | fraction (7.0) |
| --- | --- |
| `21.0` | `"0.21"` |
| `9.0` | `"0.09"` |
| `0.0` | `"0.00"` |

Divide by 100 and format as a string. A stray `21.0` is rejected by the API rather than
interpreted as 2100%.

### 3. Invoice line items

These changes apply to `invoices.create` and to the line items returned by `invoices.index` and
`invoices.show`:

| 6.x | 7.0 |
| --- | --- |
| `units: 4` | `quantity: "4"` |
| `amount_per_unit: {value:, currency:}` | `amount: {amount:, currency:}` |
| `vat: 21.0` | `vat: {value: "0.21", category: nil}` |
| `total_amount_excl_vat: {value:, currency:}` | `total_amount_ex_vat: {amount:, currency:}` |

`description`, `quantity`, `amount` and `vat` are required when creating an invoice.
`total_amount_ex_vat` appears in responses only. Every number in a line item is a string.

```ruby
# 6.x
{description: "Your product", units: 4, amount_per_unit: {value: "499.00", currency: "EUR"}, vat: 21.0}

# 7.0
{
  description: "Your product",
  quantity: "4",
  amount: {amount: "499.00", currency: "EUR"},
  vat: {value: "0.21", category: nil}
}
```

### 4. Invoice responses are flat

`invoices.show` and `invoices.index` no longer nest the customer in a `recipient` object, and
the identifier is `id` rather than `invoice_id`. The customer fields are flat and carry a
`customer_` prefix:

```ruby
# 6.x
invoice['invoice_id']
invoice.dig('recipient', 'company_name')
invoice.dig('recipient', 'address', 'postal_code')
invoice.dig('recipient', 'address', 'country', 'code')

# 7.0
invoice['id']
invoice['customer_company_name']
invoice['customer_address_postal_code']
invoice['customer_address_country_code']
```

This one is silent: `invoice['recipient']` simply returns `nil`, so a missed call site surfaces
as a `NoMethodError` on `nil` further downstream.

### 5. Customer VAT rates: `vat_percentages` becomes `vats`

The endpoint no longer returns named rates. It returns a list, and each `value` is a fraction:

```ruby
# 6.x
jortt.customers.vat_percentages(id)
# => {"id" => "...", "vat_percentages" => {"standard_rate" => "21.0", "reduced_rate" => ["9.0", "0.0"]}}

# 7.0
jortt.customers.vats(id)
# => {"id" => "...", "vats" => [{"value" => "0.21", "category" => nil}, ...]}
```

`customers.vat_percentages` remains as a deprecated alias for `customers.vats`, so existing
calls keep working — but the response shape changed either way, so the code reading the result
still needs updating.

### 6. `expenses.index` no longer accepts `query:`

The `/v3` expenses endpoint dropped free-text search. Passing `query:` now raises
`ArgumentError: unknown keyword: :query`. Filter by date range or `expense_type` instead.

### 7. `Jortt::Client::DEFAULT_SCOPE` is public

The default scope list is now a constant, which makes it easier to request an extra scope
without restating the whole list:

```ruby
Jortt.client(id, secret, scope: "#{Jortt::Client::DEFAULT_SCOPE} expenses:write")
```
