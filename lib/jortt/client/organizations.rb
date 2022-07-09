# frozen_string_literal: true

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for the Organization logged in.
    #
    # @see { Jortt::Client.organizations }
    class Organizations
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      ##
      # Returns the Organization associated with the credentials.
      # https://developer.jortt.nl/#jortt-api-organizations
      #
      # @example
      #   client.organizations.me
      #
      def me
        client.get('/organizations/me')
      end
    end
  end
end
