# encoding: UTF-8
require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of invoices.
    #
    # @see { Jortt::Client.invoices }
    class Invoices

      def initialize(config)
        @resource = RestClient::Resource.new(
          "#{config.base_url}/invoices",
          user: config.app_name,
          password: config.api_key,
        )
      end

      ##
      # Creates an Invoice using the POST /invoices endpoint.
      # See https://app.jortt.nl/api-documentatie#factuur-aanmaken
      #
      # @example
      #   Jortt::Client.invoices.create(
      #     customer_id: 'customer_id', # optional
      #     delivery_period: '31-12-2015', # optional
      #     reference: 'reference', # optional
      #     line_items: [{
      #       vat: 21, # mandatory, percentage
      #       amount: 499, # mandatory, ex vat
      #       quantity: 4, # mandatory
      #       description: 'Your Thinkas' # mandatory
      #     }]
      #   )
      def create(payload)
        resource.post(JSON.generate('invoice' => payload)) do |response|
          JSON.parse(response.body)
        end
      end

      def get(id)
        resource["id/#{id}"].get do |response|
          JSON.parse(response.body)
        end
      end

      def search(query)
        resource['search'].get(params: {query: query}) do |response|
          JSON.parse(response.body)
        end
      end

    private

      attr_reader :resource

    end

  end
end
