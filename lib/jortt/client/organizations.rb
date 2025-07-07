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
      # Returns the Organization associated with the credentials.
      # https://developer.jortt.nl/#jortt-api-organizations
      #
      # @example
      #   client.organizations.me
      #
      def me
        client.get(make_path('/organizations/me'))
      end

      ##
      # Creates an Organization using the POST /organizations/create endpoint.
      # https://developer.jortt.nl/#jortt-api-organizations
      #
      # @example
      #   client.invoices.create(
      #     email: "info@example.com",
      #     coc_number: "3456789",
      #     first_name: "John",
      #     last_name: "Doe",
      #     shop: "the-shop",
      #   )
      def create(payload)
        client.post(make_path('/organizations/create'), payload)
      end
    end
  end
end
