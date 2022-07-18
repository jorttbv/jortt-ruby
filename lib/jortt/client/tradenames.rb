# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of tradenames.
    #
    # @see { Jortt::Client.tradenames }
    class Tradenames < Base
      ##
      # Returns all tradenames using the GET /tradenames endpoint.
      # https://developer.jortt.nl/#list-tradenames
      #
      # @example
      #   client.tradenames.index
      #
      def index
        client.get(make_path('/tradenames'))
      end
    end
  end
end
