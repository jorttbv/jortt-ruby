# frozen_string_literal: true

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of tradenames.
    #
    # @see { Jortt::Client.tradenames }
    class Tradenames
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      ##
      # Returns all tradenames using the GET /tradenames endpoint.
      # https://developer.jortt.nl/#list-tradenames
      #
      # @example
      #   client.tradenames.index
      #
      def index
        client.paginated('/tradenames')
      end
    end
  end
end
