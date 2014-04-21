require 'freemle/client/resource'

module Freemle

  ##
  # This class is the main interface used to communicate with the Freemle API.
  # It is by the {Freemle} module to create configured instances.

  class Client
    BASE_URL = 'https://www.freemle.com/api'

    attr_accessor :base_url, :app_name, :api_key

    # Initialize a Freemle client.
    #
    # @example
    #   Freemle::Client.new(
    #     app_name: <application-name, chosen in freemle.com>
    #     api_key: <api-key, as provided by freemle.com>
    #   )
    #
    # @params [ Hash ] opts Options for the client,
    #   optionally including base_url.
    #
    # @return [ Freemle::Client ]
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
    # @return [ Freemle::Client::Resource ] entry to the customer resource.
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
    # @return [ Freemle::Client::Resource ] entry to the invoice resource.
    #
    # @since 1.0.0
    def invoices
      @invoices ||= new_resource(self, :invoice, :invoices)
    end

  private

    # Creates a freemle client resource based on the passed configuration
    #
    # @return [ Freemle::Client::Resource ] entry to a resource.
    #
    # @since 1.0.1
    def new_resource(*args)
      Freemle::Client::Resource.new(*args)
    end

  end
end
