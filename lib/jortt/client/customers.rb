# frozen_string_literal: true

require_relative 'base'

module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class Customers < Base
      ##
      # Returns all customers using the GET /customers endpoint.
      # https://developer.jortt.nl/#list-customers
      #
      # @example
      #   client.customers.index(query: 'Jane')
      #
      def index(query: nil)
        client.paginated(make_path('/customers'), query: query)
      end

      ##
      # Returns a customer using the GET /customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#get-customer-by-id
      #
      # @example
      #   client.customers.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        client.get(make_path("/customers/#{id}"))
      end

      ##
      # Creates a Customer using the POST /customers endpoint.
      # https://developer.jortt.nl/#create-customer
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
        client.post(make_path('/customers'), payload)
      end

      ##
      # Updates a Customer using the PUT /customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#update-customer
      #
      # @example
      #   client.customers.update(
      #     "9afcd96e-caf8-40a1-96c9-1af16d0bc804",
      #     { address_extra_information: 'foobar' }
      #   )
      #
      def update(id, payload)
        client.put(make_path("/customers/#{id}"), payload)
      end

      ##
      # Deletes a Customer using the DELETE /customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#delete-a-customer
      #
      # @example
      #   client.customers.delete("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def delete(id)
        client.delete(make_path("/customers/#{id}"))
      end

      ##
      # Send direct debit authorization to a Customer using POST /customers/{customer_id}/direct_debit_mandate.
      # https://developer.jortt.nl/#send-direct-debit-authorization-to-a-customer
      #
      # @example
      #   client.customers.direct_debit_mandate("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def direct_debit_mandate(id)
        client.post(make_path("/customers/#{id}/direct_debit_mandate"))
      end

      ##
      # Get vat percentages for a Customer using the GET /customers/{customer_id}/vat-percentages endpoint.
      # https://developer.jortt.nl/#get-vat-percentages-for-a-customer-by-id
      #
      # @example
      #   client.customers.vat_percentages("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def vat_percentages(id)
        client.get(make_path("/customers/#{id}/vat-percentages"))
      end
    end
  end
end
