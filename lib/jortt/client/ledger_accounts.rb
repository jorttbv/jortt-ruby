module Jortt # :nodoc:
  class Client # :nodoc:
    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class LedgerAccounts
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      ##
      # Returns the list of Ledger Accounts that can be used to categorize Line Items on an Invoice
      # for in your Profit and Loss report using the GET /ledger_accounts/invoices endpoint.
      # https://developer.jortt.nl/#list-invoice-ledger-accounts
      #
      # @example
      #   client.ledger_accounts.index
      #
      def index
        client.get('/ledger_accounts/invoices')
      end
    end
  end
end
