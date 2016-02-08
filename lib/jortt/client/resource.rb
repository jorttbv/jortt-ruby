# encoding: UTF-8
require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # This class is used by {Jortt::Client} internally.
    # It wraps rest API calls of a single resource,
    # so they can easily be used using the client DSL.
    #
    # @see { Jortt::Client.customer }
    class Resource

      # Details needed to connect to this resource, see
      # +Jortt::Client#initialize+
      #
      # @since 1.0.0
      attr_accessor :config

      # The singular form, posted to and returned when describing
      # a single member of this resource.
      #
      # @since 1.0.0
      attr_accessor :singular

      # Used to describe multiple members of this resource.
      #
      # @since 1.0.0
      attr_accessor :plural

      # Creates a new resource instance.
      #
      # @see { Jortt::Client#new_resource }
      #
      # @returns [ Jortt::Client::Resource ] bound to the resource
      # defined by +singular+ & +plural+
      #
      # @since 1.0.0
      def initialize(config, singular, plural)
        self.config = config
        self.singular = singular
        self.plural = plural
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
      def search(query, &block)
        block = default_handler unless block_given?
        request.get(params: {query: query}, &block)
      end

      # Persists a resource on jortt.com, given a payload.
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
        request.post(json.generate(singular => payload), &block)
      end

    private

      # Returns a response handler, which parses the response body as JSON.
      #
      # @return [ Proc ] Default response handler.
      #
      # @since 1.0.0
      def default_handler
        proc { |response| json.parse(response.body) }
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
          password: config.api_key,
        )
      end

      # Returns the JSON library used in request/default-response handling.
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
