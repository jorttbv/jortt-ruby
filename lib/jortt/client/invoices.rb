# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of invoices.
    #
    # Line items require +description+, +quantity+, +amount+ and +vat+, where
    # +vat.value+ is a fraction rather than a percentage.
    #
    # @see { Jortt::Client.invoices }
    # @see https://developer.jortt.nl/#tag-v3-invoices
    class Invoices < Base
      ##
      # Returns all invoices using the GET /v3/invoices endpoint.
      # https://developer.jortt.nl/#v3-list-invoices-v3
      #
      # @example
      #   client.invoices.index(query: 'Jane')
      #
      def index(query: nil, invoice_status: nil)
        client.paginated(make_path('/v3/invoices'), query: query, invoice_status: invoice_status)
      end

      ##
      # Returns an invoice using the GET /v3/invoices/{invoice_id} endpoint.
      # https://developer.jortt.nl/#v3-get-invoice-by-id-v3
      #
      # @example
      #   client.invoices.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        client.get(make_path("/v3/invoices/#{id}"))
      end

      ##
      # Creates an Invoice using the POST /v3/invoices endpoint.
      # https://developer.jortt.nl/#v3-create-and-optionally-send-an-invoice-v3
      #
      # @example
      #   client.invoices.create(
      #     customer_id: "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     line_items: [{
      #       description: "Your product",
      #       quantity: "4",
      #       amount: { amount: "499.00", currency: "EUR" },
      #       vat: { value: "0.21", category: nil }
      #     }]
      #   )
      def create(payload)
        client.post(make_path('/v3/invoices'), payload)
      end

      ##
      # Credits an Invoice using the POST /v3/invoices/{invoice_id}/credit endpoint.
      # https://developer.jortt.nl/#v3-creates-and-optionally-sends-a-credit-invoice
      #
      # @example
      #   client.invoices.credit(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     {
      #       send_method: 'email'
      #     }
      #   )
      def credit(id, payload)
        client.post(make_path("/v3/invoices/#{id}/credit"), payload)
      end

      ##
      # Returns an invoice PDF download link using the GET /v3/invoices/{invoice_id}/download endpoint.
      # https://developer.jortt.nl/#v3-download-invoice-pdf
      #
      # @example
      #   client.invoices.download("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def download(id)
        client.get(make_path("/v3/invoices/#{id}/download"))
      end
    end
  end
end
