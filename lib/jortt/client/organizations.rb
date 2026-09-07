# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for the Organization logged in.
    #
    # @see { Jortt::Client.organizations }
    class Organizations < Base
      ##
      # Returns the Organization associated with the credentials
      # using the GET /v3/organizations/me endpoint.
      # https://developer.jortt.nl/#v3-get-the-organization-associated-with-the-api-credentials
      #
      # @example
      #   client.organizations.me
      #
      def me
        client.get(make_path('/v3/organizations/me'))
      end
    end
  end
end
