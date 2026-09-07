# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    # @see https://developer.jortt.nl/#tag-v3-customers
    class Customers < Base
      ##
      # Returns all customers using the GET /v3/customers endpoint.
      # https://developer.jortt.nl/#v3-list-customers
      #
      # @example
      #   client.customers.index(query: 'Jane')
      #
      # @param [String] query Search for customers that match this text. Give 3 characters or more
      #
      def index(query: nil)
        params = {query: query}.compact

        client.paginated(make_path('/v3/customers'), params)
      end

      ##
      # Returns a customer using the GET /v3/customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#v3-get-customer-by-id
      #
      # @example
      #   client.customers.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        client.get(make_path("/v3/customers/#{id}"))
      end

      ##
      # Creates a Customer using the POST /v3/customers endpoint.
      # https://developer.jortt.nl/#v3-create-customer
      #
      # @example
      #   client.customers.create(
      #     is_private: false,
      #     customer_name: 'Nuka-Cola Corporation',
      #     address_street: 'Vault 11',
      #     address_postal_code: '1111AA',
      #     address_city: 'Mojave Wasteland'
      #   )
      #
      def create(payload)
        client.post(make_path('/v3/customers'), payload)
      end

      ##
      # Updates a Customer using the PUT /v3/customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#v3-update-customer
      #
      # @example
      #   client.customers.update(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     { address_extra_information: 'foobar' }
      #   )
      #
      def update(id, payload)
        client.put(make_path("/v3/customers/#{id}"), payload)
      end

      ##
      # Deletes a Customer using the DELETE /v3/customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#v3-delete-a-customer
      #
      # @example
      #   client.customers.delete("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def delete(id)
        client.delete(make_path("/v3/customers/#{id}"))
      end

      ##
      # Send direct debit authorization to a Customer using
      # POST /v3/customers/{customer_id}/direct_debit_mandate.
      # https://developer.jortt.nl/#v3-send-direct-debit-authorization-to-a-customer
      #
      # @example
      #   client.customers.direct_debit_mandate("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def direct_debit_mandate(id)
        client.post(make_path("/v3/customers/#{id}/direct_debit_mandate"))
      end

      ##
      # Get the vats valid for a Customer using the
      # GET /v3/customers/{customer_id}/vat-percentages endpoint.
      # https://developer.jortt.nl/#v3-get-vat-percentages-for-a-customer-by-id-v2
      #
      # The path still contains +vat-percentages+, but the endpoint no longer returns named
      # percentages. The endpoint returns a flat list of vats. Each +value+ is a fraction:
      #
      #   { "id" => "...", "vats" => [{ "value" => "0.21", "category" => nil }] }
      #
      # @example
      #   client.customers.vats("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def vats(id)
        client.get(make_path("/v3/customers/#{id}/vat-percentages"))
      end

      # @deprecated Use {#vats}. Version 7.0 renamed this method, because the endpoint no
      #   longer returns percentages.
      alias vat_percentages vats
    end
  end
end
