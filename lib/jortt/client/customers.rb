require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class Customers < Client

      def initialize(config)
        @resource = RestClient::Resource.new(
          "#{config.base_url}/customers",
          user: config.app_name,
          password: config.api_key,
        )
      end

      ##
      # Returns all customers using the GET /customers/all endpoint.
      #
      # @example
      #   Jortt::Client.customers.all(page: 3, per_page: 10)
      #
      def all(page: 1, per_page: 50)
        with_valid_json do
          resource['all'].get(params: {page: page, per_page: per_page})
        end
      end

      ##
      # Creates a Customer using the POST /customers endpoint.
      # See https://app.jortt.nl/api-documentatie#klant-aanmaken
      #
      # @example
      #   Jortt::Client.customers.create(
      #     company_name: "Jortt B.V.", # mandatory
      #     attn: "Finance department", # optional
      #     email: "support@jortt.nl", # optional
      #     extra_information: "Our valued customer", # optional
      #     address: {
      #       street: "Street 100", # mandatory
      #       postal_code: "1000 AA", # mandatory
      #       city: "Amsterdam", # mandatory
      #       country_code: "NL" # mandatory
      #     }
      #   )
      def create(payload)
        with_valid_json do
          resource.post(JSON.generate('customer' => payload))
        end
      end

      # Performs a search on this resource, given a query.
      #
      # @example
      #   customers.search('Zilverline')
      #
      # @example
      #   customers.search('Zilverline') do |response|
      #     # Roll your own response handler
      #   end
      #
      # @param [ Hash ] query A hash containing the fields to search for.
      # @param [ Proc ] block A custom response handler.
      #
      # @return [ Array<Hash> ] By default, a JSON parsed response body.
      #
      # @since 1.0.0
      def search(query)
        with_valid_json do
          resource.get(params: {query: query})
        end
      end

    private

      attr_reader :resource

    end
  end
end
