require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of invoices.
    #
    # @see { Jortt::Client.invoices }
    class Invoices
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      ##
      # Returns all invoices using the GET /invoices endpoint.
      #
      # @example
      #   client.invoices.index(page: 3, query: 'Jane')
      #
      def index(page: 1, query: nil, invoice_status: nil)
        params = {
          page: page,
          query: query,
          invoice_status: invoice_status
        }

        token.get('/invoices', params: params).parsed.fetch('data')
      end

      ##
      # Returns a invoice using the GET /invoices/{invoice_id} endpoint.
      #
      # @example
      #   client.invoices.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        token.get("/invoices/#{id}").parsed.fetch('data')
      end

      ##
      # Creates an Invoice using the POST /invoices endpoint.
      #
      # @example
      #   client.invoices.create(
      #     line_items: [{
      #       vat: 21,
      #       amount: 499,
      #       units: 4,
      #       description: 'Your product'
      #     }]
      #   )
      def create(payload)
        token.post('/invoices', params: payload).parsed.fetch('data')
      end

      ##
      # Returns an invoice PDF download link using the GET /invoices/{invoice_id}/download endpoint.
      #
      # @example
      #   client.invoices.download("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def download(id)
        token.get("/invoices/#{id}/download").parsed.fetch('data')
      end
    end
  end
end
