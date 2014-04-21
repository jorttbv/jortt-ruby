require 'rest-client'

module Freemle
  class Client

    ##
    # This class is used by {Freemle::Client} internally.
    # It wraps rest API calls of a single resource,
    # so they can easily be used using the client DSL.
    # @see {Freemle::Client.customer}

    class Resource < Struct.new(:config, :singular, :plural)

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
      def search(query, &block)
        block = default_handler unless block_given?
        request.get(params: {query: query}, &block)
      end

      # Persists a resource on freemle.com, given a payload.
      #
      # @example
      #   customers.create(
      #     company_name: "Zilverline B.V.",
      #     address: {
      #       street: "Cruquiusweg 109 F",
      #       postal_code: "1019 AG",
      #       city: "Amsterdam",
      #       country_code: "NL"
      #     }
      #   )
      #
      # @example
      #   customers.create(
      #     company_name: "Zilverline B.V.",
      #     address: {
      #       street: "Cruquiusweg 109 F",
      #       postal_code: "1019 AG",
      #       city: "Amsterdam",
      #       country_code: "NL"
      #     }
      #   ) do |response|
      #     # Roll your own response handler
      #   end
      #
      # @param [ Hash ] payload A hash containing the fields to set.
      # @param [ Proc ] block A custom response handler.
      #
      # @return [ Hash ] By default, a JSON parsed response body.
      #
      # @since 1.0.0
      def create(payload, &block)
        block = default_handler unless block_given?
        request.post(json.generate({singular => payload}), &block)
      end

    private

      # Returns a response handler, which parses the response body as JSON.
      #
      # @return [ Proc ] Default response handler.
      #
      # @since 1.0.0
      def default_handler
        Proc.new { |response| json.parse(response.body) }
      end

      # Returns a new request handler for this resource.
      #
      # @return [ RestClient::Resource ] A request handler.
      #
      # @since 1.0.0
      def request
        RestClient::Resource.new(
          "#{config.base_url}/#{plural}",
          user: config.app_name,
          password: config.api_key
        )
      end

      # Returns the JSON library used in request and default response handling.
      #
      # @return [ Class ] A JSON library.
      #
      # @since 1.0.0
      def json
        return @json if @json
        require 'json'
        @json = JSON
      end

    end
  end
end
