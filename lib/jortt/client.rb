# encoding: UTF-8
require 'jortt/client/resource'
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

    # Access the customer resource.
    #
    # @example
    #   client.customers
    #
    # @return [ Jortt::Client::Resource ] entry to the customer resource.
    #
    # @since 1.0.0
    def customers
      @customers ||= new_resource(self, :customer, :customers)
    end

    # Access the invoice resource.
    #
    # @example
    #   client.invoices
    #
    # @return [ Jortt::Client::Resource ] entry to the invoice resource.
    #
    # @since 1.0.0
    def invoices
      @invoices ||= new_resource(self, :invoice, :invoices)
    end

    def invoice(invoice_id)
      Jortt::Client::Invoice.new(self, invoice_id)
    end

  private

    # Creates a jortt client resource based on the passed configuration
    #
    # @return [ Jortt::Client::Resource ] entry to a resource.
    #
    # @since 1.0.1
    def new_resource(*args)
      Jortt::Client::Resource.new(*args)
    end

  end
end
