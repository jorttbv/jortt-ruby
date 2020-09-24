require 'jortt/client/resource'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class Customers < Resource
      ##
      # Returns all customers using the GET /customers endpoint.
      # https://developer.jortt.nl/#list-customers
      #
      # @example
      #   client.customers.index(query: 'Jane')
      #
      def index(query: nil)
        paginated('/customers', query: query)
      end

      ##
      # Returns a customer using the GET /customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#get-customer-by-id
      #
      # @example
      #   client.customers.show("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def show(id)
        get("/customers/#{id}")
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
        post('/customers', payload)
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
        put("/customers/#{id}", payload)
      end

      ##
      # Deletes a Customer using the DELETE /customers/{customer_id} endpoint.
      # https://developer.jortt.nl/#delete-a-customer
      #
      # @example
      #   client.customers.delete("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #
      def delete(id)
        response = token.delete("/customers/#{id}")
        response.status == 204
      end

      ##
      # Send direct debit authorization to a Customer using POST /customers/{customer_id}/direct_debit_mandate.
      # https://developer.jortt.nl/#send-direct-debit-authorization-to-a-customer
      #
      # @example
      #   client.customers.direct_debit_mandate("9afcd96e-caf8-40a1-96c9-1af16d0bc804")
      #

      def direct_debit_mandate(id)
        response = token.post("/customers/#{id}/direct_debit_mandate").parsed.fetch('data')
        response.status == 204
      end
    end
  end
end
