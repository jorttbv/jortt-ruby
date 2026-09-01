# Changelog

All notable changes to this gem are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.0.0] - 2026-09-01

Every request now targets the `/v3` API, which renames several fields. See
[UPGRADING.md](UPGRADING.md) for a migration guide.

### Added

- Expenses resource: `expenses.index`, `show`, `create`, `update` and `attach_receipt`.
- Organizations resource: `organizations.me`.
- Tradenames resource: `tradenames.index`.
- Support for the authorization code grant type, alongside client credentials.
- `Jortt::Client::DEFAULT_SCOPE`, so an extra scope can be requested without restating the
  whole list: `scope: "#{Jortt::Client::DEFAULT_SCOPE} expenses:write"`.
- `expenses:read` and `organizations:read` in the default scope.
- `Jortt::Client::ServerError`, raised for `5xx` responses. `Jortt::Client::JorttError` still
  covers `4xx`, and both inherit from `Jortt::Client::Error`.
- `customers.vats`, replacing `customers.vat_percentages`.
- A `site:` option that includes a path is now honoured when building resource paths.

### Changed

- **Breaking.** All requests go to `/v3`. The unversioned and `/v1` endpoints used by 5.x and
  6.x are being discontinued by Jortt.
- **Breaking.** Money objects key on `amount` instead of `value`:
  `{amount: "12.34", currency: "EUR"}`. Applies to `invoice_total`, `invoice_total_incl_vat`,
  `invoice_due_amount` and every line item amount.
- **Breaking.** VAT is an object whose `value` is a fraction rather than a percentage:
  `vat: {value: "0.21", category: nil}` instead of `vat: 21.0`.
- **Breaking.** Invoice line items rename `units` to `quantity`, `amount_per_unit` to `amount`,
  and `total_amount_excl_vat` to `total_amount_ex_vat`.
- **Breaking.** Invoice responses are flat. `invoice_id` is now `id`, and the nested `recipient`
  object is replaced by `customer_*` fields.
- **Breaking.** `customers.vat_percentages` returns a `vats` array of `{value:, category:}`
  objects rather than a `vat_percentages` hash of named rates.
- POST and PUT payloads are sent as JSON in the request body.
- **Breaking.** The `oauth2` dependency moved from `~> 1.4.4` to `~> 2.0.5`. Applications that
  depend on `oauth2` directly need to upgrade with it.
- Ruby 2.7 through 3.3 are covered by CI.

### Deprecated

- `customers.vat_percentages` is an alias for `customers.vats`. The endpoint no longer returns
  percentages, so the response shape changed even when calling through the alias.

### Removed

- **Breaking.** `expenses.index` no longer accepts `query:`. The `/v3` endpoint dropped
  free-text search, so passing it raises `ArgumentError`. Filter by date range or
  `expense_type` instead.

## [6.1.0] - 2021-09-29

### Added

- `customers.vat_percentages`, backed by `GET /customers/{id}/vat-percentages`.

## [6.0.0] - 2021-02-24

### Added

- Customer and invoice endpoints for the OAuth API.
- `ledger_accounts.index`.
- `invoices.credit`.
- Automatic pagination — `index` returns an enumerator that fetches pages on demand.
- `Jortt::Client::JorttError`, carrying the `code`, `key`, `message` and `details` returned by
  the API.

## [5.0.0] - 2020-09-22

Never tagged in git. The version was bumped in commit
[`2abf7bf`](https://github.com/jorttbv/jortt-ruby/commit/2abf7bf).

### Changed

- **Breaking.** First release against the new Jortt OAuth API. Integrations on the legacy API
  should stay on [4.2.0](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0).

## Earlier releases

This changelog was introduced in 7.0.0, so releases before 5.0.0 are not reconstructed here.
See the [tags](https://github.com/jorttbv/jortt-ruby/tags) and commit history for
[4.2.0](https://github.com/jorttbv/jortt-ruby/tree/v4.2.0) (2017-06-26),
[3.0.0](https://github.com/jorttbv/jortt-ruby/tree/v3.0.0) (2016-02-08),
[2.0.0](https://github.com/jorttbv/jortt-ruby/tree/v2.0.0) (2015-08-19),
[1.0.1](https://github.com/jorttbv/jortt-ruby/tree/v1.0.1) and
[1.0.0](https://github.com/jorttbv/jortt-ruby/tree/v1.0.0) (2014-04-18), and
[0.0.1](https://github.com/jorttbv/jortt-ruby/tree/v0.0.1) (2014-03-28).

[7.0.0]: https://github.com/jorttbv/jortt-ruby/compare/v6.1.0...master
[6.1.0]: https://github.com/jorttbv/jortt-ruby/compare/v6.0.0...v6.1.0
[6.0.0]: https://github.com/jorttbv/jortt-ruby/compare/2abf7bf...v6.0.0
[5.0.0]: https://github.com/jorttbv/jortt-ruby/compare/v4.2.0...2abf7bf
