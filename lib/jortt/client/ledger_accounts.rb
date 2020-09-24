require 'jortt/client/resource'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a collection of customers.
    #
    # @see { Jortt::Client.customers }
    class LedgerAccounts < Resource
      ##
      # Returns the list of Ledger Accounts that can be used to categorize Line Items on an Invoice
      # for in your Profit and Loss report using the GET /ledger_accounts/invoices endpoint.
      #
      # @example
      #   client.ledger_accounts.index
      #
      def index
        get('/ledger_accounts/invoices')
      end
    end
  end
end
