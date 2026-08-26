# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of expenses.
    #
    # @see { Jortt::Client.expenses }
    # @see https://developer.jortt.nl/#tag-v3-expenses
    class Expenses < Base
      ##
      # Returns all expenses using the GET /v3/expenses endpoint.
      # https://developer.jortt.nl/#v3-list-expenses
      #
      # Returns a paginated list of Expenses for the current organization.
      # Results are ordered by expense number by default.
      #
      # Use +vat_date_from+ and +vat_date_till+ to filter by VAT date range.
      # Use +delivery_date_from+ and +delivery_date_till+ to filter by delivery period.
      #
      # @example
      #   client.expenses.index(vat_date_from: '20260101', vat_date_till: '20260331')
      #
      # @param [String] vat_date_from Filter expenses with vat_date on or after this date
      # @param [String] vat_date_till Filter expenses with vat_date on or before this date
      # @param [String] delivery_date_from Filter expenses with delivery_period on or after this date
      # @param [String] delivery_date_till Filter expenses with delivery_period on or before this date
      # @param [String] expense_type Filter by expense type: +cost+, +income+ or +balance+
      #
      def index(vat_date_from: nil, vat_date_till: nil,
                delivery_date_from: nil, delivery_date_till: nil,
                expense_type: nil)
        params = {
          vat_date_from: vat_date_from,
          vat_date_till: vat_date_till,
          delivery_date_from: delivery_date_from,
          delivery_date_till: delivery_date_till,
          expense_type: expense_type,
        }.compact

        client.paginated(make_path('/v3/expenses'), params)
      end

      ##
      # Returns an expense using the GET /v3/expenses/id/{id} endpoint.
      # https://developer.jortt.nl/#v3-get-expense-by-id
      #
      # @example
      #   client.expenses.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        client.get(make_path("/v3/expenses/id/#{id}"))
      end

      ##
      # Creates an Expense using the POST /v3/expenses endpoint.
      # https://developer.jortt.nl/#v3-create-an-expense
      #
      # +description+, +ledger_account_id+, +expense_type+, +vat_date+,
      # +delivery_period+, +vat_type+ and +raw_total_amount+ are required.
      # +expense_type+ is one of +cost+, +income+ or +balance+, and +vat_type+ is
      # one of the +btw_type_*+ values listed in the API documentation.
      #
      # @example
      #   client.expenses.create(
      #     description: 'Office equipment',
      #     ledger_account_id: '05ba2a61-a0cc-4736-9000-89fb361e85c8',
      #     expense_type: 'cost',
      #     vat_date: '2026-01-15',
      #     delivery_period: '2026-01-01',
      #     vat_type: 'btw_type_leverancier_uit_nl',
      #     raw_total_amount: { amount: '121.00', currency: 'EUR' },
      #     vat_line_items: [{
      #       vat: { value: '0.21', category: nil },
      #       vat_amount: { amount: '21.00', currency: 'EUR' }
      #     }]
      #   )
      #
      def create(payload)
        client.post(make_path('/v3/expenses'), payload)
      end

      ##
      # Updates an Expense using the POST /v3/expenses/id/{id} endpoint.
      # https://developer.jortt.nl/#v3-update-an-expense
      #
      # Takes the same fields as {#create}, and the same fields are required, so
      # send the complete Expense rather than only the fields that changed.
      #
      # @example
      #   client.expenses.update(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     {
      #       description: 'Updated description',
      #       ledger_account_id: '05ba2a61-a0cc-4736-9000-89fb361e85c8',
      #       expense_type: 'cost',
      #       vat_date: '2026-01-15',
      #       delivery_period: '2026-01-01',
      #       vat_type: 'btw_type_leverancier_uit_nl',
      #       raw_total_amount: { amount: '121.00', currency: 'EUR' }
      #     }
      #   )
      #
      def update(id, payload)
        client.post(make_path("/v3/expenses/id/#{id}"), payload)
      end

      ##
      # Attaches a receipt to an Expense using the POST /v3/expenses/id/{id}/receipt endpoint.
      # https://developer.jortt.nl/#v3-attach-a-receipt-to-an-expense
      #
      # +receipt_id+ is the identifier of a file uploaded through
      # POST /v3/files/attachment_upload.
      #
      # @example
      #   client.expenses.attach_receipt(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     { receipt_id: '1aa9cd93-aa14-4184-ba01-1fa2776d2e2d' }
      #   )
      #
      def attach_receipt(id, payload)
        client.post(make_path("/v3/expenses/id/#{id}/receipt"), payload)
      end
    end
  end
end
