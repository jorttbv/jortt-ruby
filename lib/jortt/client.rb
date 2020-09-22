require 'jortt/client/customers'
require 'jortt/client/invoices'
require 'jortt/client/ledger_accounts'

module Jortt
  ##
  # This class is the main interface used to communicate with the Jortt API.
  # It is by the {Jortt} module to create configured instances.
  class Client
    SITE = 'https://api.jortt.nl'
    OAUTH_PROVIDER_URL = 'https://app.jortt.nl/oauth-provider/oauth'

    attr_accessor :token

    # Initialize a Jortt client.
    #
    # @example
    #   Jortt::Client.new(
    #     "my-client-id",
    #     "my-client-secret"
    #   )
    #
    # @params [ Hash ] opts Options for the client,
    #   optionally including base_url.
    #
    # @return [ Jortt::Client ]
    #
    # @since 1.0.0
    def initialize(id, secret, opts = {})
      oauth_provider_url = opts[:oauth_provider_url] || OAUTH_PROVIDER_URL

      client = OAuth2::Client.new(id, secret,
        site: opts[:site] || SITE,
        token_url: "#{oauth_provider_url}/token",
        authorize_url: "#{oauth_provider_url}/authorize",
        auth_scheme: :basic_auth
      )

      @token = client.client_credentials.get_token(scope: "invoices:read invoices:write customers:read customers:write")
    end

    # Access the customer resource to perform operations.
    #
    # @example
    #   client.customers
    #
    # @return [ Jortt::Client::Customers ] entry to the customer resource.
    #
    # @since 1.0.0
    def customers
      @customers ||= Jortt::Client::Customers.new(token)
    end

    # Access the invoices resource to perform operations.
    #
    # @example
    #   client.invoices
    #
    # @return [ Jortt::Client::Invoices ] entry to the invoice resource.
    #
    # @since 1.0.0
    def invoices
      @invoices ||= Jortt::Client::Invoices.new(token)
    end

    # Access the ledger_accounts resource.
    #
    # @example
    #   client.ledger_accounts
    #
    # @return [ Jortt::Client::LedgerAccounts ] entry to the leger_accounts resource.
    #
    # @since 5.0.0
    def ledger_accounts
      Jortt::Client::LedgerAccounts.new(token)
    end

  end
end
