# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of invoices.
    #
    # @see { Jortt::Client.invoices }
    class Invoices < Base
      ##
      # Returns all invoices using the GET /invoices endpoint.
      # https://developer.jortt.nl/#list-invoices
      #
      # @example
      #   client.invoices.index(query: 'Jane')
      #
      def index(query: nil, invoice_status: nil)
        client.paginated(make_path('/invoices'), query: query, invoice_status: invoice_status)
      end

      ##
      # Returns a invoice using the GET /invoices/{invoice_id} endpoint.
      # https://developer.jortt.nl/#get-invoice-by-id
      #
      # @example
      #   client.invoices.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        client.get(make_path("/invoices/#{id}"))
      end

      ##
      # Creates an Invoice using the POST /invoices endpoint.
      # https://developer.jortt.nl/#create-and-optionally-send-an-invoice
      #
      # @example
      #   client.invoices.create(
      #     line_items: [{
      #       vat_percentage: "21.0",
      #       amount: 499,
      #       number_of_units: "4",
      #       description: 'Your product'
      #     }]
      #   )
      def create(payload)
        client.post(make_path('/invoices'), payload)
      end

      ##
      # Credits an Invoice using the POST /invoices/{invoice_id}/credit endpoint.
      # https://developer.jortt.nl/#create-and-optionally-send-an-invoice
      #
      # @example
      #   client.invoices.credit(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     {
      #       send_method: 'email'
      #     }
      #   )
      def credit(id, payload)
        client.post(make_path("/invoices/#{id}/credit"), payload)
      end

      ##
      # Returns an invoice PDF download link using the GET /invoices/{invoice_id}/download endpoint.
      # https://developer.jortt.nl/#download-invoice-pdf
      #
      # @example
      #   client.invoices.download("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def download(id)
        client.get(make_path("/invoices/#{id}/download"))
      end
    end
  end
end
