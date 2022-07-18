# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for the Organization logged in.
    #
    # @see { Jortt::Client.organizations }
    class Organizations <  Base
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
    end
  end
end
