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
      # @param [String] query Free-text search query
      # @param [String] vat_date_from Filter expenses with vat_date on or after this date
      # @param [String] vat_date_till Filter expenses with vat_date on or before this date
      # @param [String] delivery_date_from Filter expenses with delivery_period on or after this date
      # @param [String] delivery_date_till Filter expenses with delivery_period on or before this date
      # @param [String] expense_type Filter by expense type
      #
      def index(query: nil, vat_date_from: nil, vat_date_till: nil,
                delivery_date_from: nil, delivery_date_till: nil,
                expense_type: nil)
        params = {
          query: query,
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
      # @example
      #   client.expenses.create(
      #     expense_date: '2026-01-15',
      #     vat_date: '2026-01-15',
      #     supplier_name: 'Office Supplies B.V.',
      #     description: 'Office equipment',
      #     line_items: [{
      #       amount: { value: '100.00', currency: 'EUR' },
      #       vat_percentage: '21.0',
      #       ledger_account_id: 'ledger-uuid'
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
      # @example
      #   client.expenses.update(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     { description: 'Updated description' }
      #   )
      #
      def update(id, payload)
        client.post(make_path("/v3/expenses/id/#{id}"), payload)
      end

      ##
      # Attaches a receipt to an Expense using the POST /v3/expenses/id/{id}/receipt endpoint.
      # https://developer.jortt.nl/#v3-attach-a-receipt-to-an-expense
      #
      # @example
      #   client.expenses.attach_receipt(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     { file_id: 'file-uuid' }
      #   )
      #
      def attach_receipt(id, payload)
        client.post(make_path("/v3/expenses/id/#{id}/receipt"), payload)
      end
    end
  end
end
