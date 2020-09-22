require 'oauth2'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class LedgerAccounts
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      ##
      # Returns the list of Ledger Accounts that can be used to categorize Line Items on an Invoice
      # for in your Profit and Loss report using the GET /ledger_accounts/invoices endpoint.
      #
      # @example
      #   client.ledger_accounts.index
      #
      def index
        token.get('/ledger_accounts/invoices').parsed.fetch('data')
      end
    end
  end
end
