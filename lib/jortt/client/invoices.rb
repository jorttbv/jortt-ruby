require 'jortt/client/resource'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of invoices.
    #
    # @see { Jortt::Client.invoices }
    class Invoices < Resource
      ##
      # Returns all invoices using the GET /invoices endpoint.
      #
      # @example
      #   client.invoices.index(page: 3, query: 'Jane')
      #
      def index(page: 1, query: nil, invoice_status: nil)
        get('/invoices', page: page, query: query, invoice_status: invoice_status)
      end

      ##
      # Returns a invoice using the GET /invoices/{invoice_id} endpoint.
      #
      # @example
      #   client.invoices.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        get("/invoices/#{id}")
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
        post('/invoices', payload)
      end

      ##
      # Returns an invoice PDF download link using the GET /invoices/{invoice_id}/download endpoint.
      #
      # @example
      #   client.invoices.download("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def download(id)
        get("/invoices/#{id}/download")
      end
    end
  end
end
