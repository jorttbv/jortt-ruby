require 'jortt/client/customers'
require 'jortt/client/invoices'
require 'jortt/client/invoice'

module Jortt
  ##
  # This class is the main interface used to communicate with the Jortt API.
  # It is by the {Jortt} module to create configured instances.
  class Client
    BASE_URL = 'https://app.jortt.nl/api'

    attr_accessor :base_url, :app_name, :api_key

    # Initialize a Jortt client.
    #
    # @example
    #   Jortt::Client.new(
    #     app_name: <application-name, chosen in jortt.nl>
    #     api_key: <api-key, as provided by jortt.nl>
    #   )
    #
    # @params [ Hash ] opts Options for the client,
    #   optionally including base_url.
    #
    # @return [ Jortt::Client ]
    #
    # @since 1.0.0
    def initialize(opts)
      self.base_url = opts.fetch(:base_url, BASE_URL)
      self.app_name = opts.fetch(:app_name)
      self.api_key = opts.fetch(:api_key)
    end

    # Access the customer resource to perform operations.
    #
    # @example
    #   client.customers
    #
    # @return [ Jortt::Client::Customers ] entry to the customer resource.
    #
    # @since 1.0.0
    def customers
      @customers ||= Jortt::Client::Customers.new(self)
    end

    # Access the invoices resource to perform operations.
    #
    # @example
    #   client.invoices
    #
    # @return [ Jortt::Client::Invoices ] entry to the invoice resource.
    #
    # @since 1.0.0
    def invoices
      @invoices ||= Jortt::Client::Invoices.new(self)
    end

    # Access a single invoice resource to perform operations.
    #
    # @example
    #   client.invoice('abc')
    #
    # @params [ String ] invoice_id The id of an invoice.
    #
    # @return [ Jortt::Client::Invoice ] entry to the invoice resource.
    def invoice(invoice_id)
      Jortt::Client::Invoice.new(self, invoice_id)
    end

  end
end
