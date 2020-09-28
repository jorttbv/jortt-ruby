require 'oauth2'

require 'jortt/client/error'
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
      @customers ||= Jortt::Client::Customers.new(self)
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
      @invoices ||= Jortt::Client::Invoices.new(self)
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
      Jortt::Client::LedgerAccounts.new(self)
    end

    def get(path, params = {})
      handle_response { token.get(path, params: params) }
    end

    def post(path, params = {})
      handle_response { token.post(path, params: params) }
    end

    def put(path, params = {})
      handle_response { token.put(path, params: params) }
    end

    def delete(path)
      handle_response { token.delete(path) }
    end

    def handle_response(&block)
      response = yield
      return true if response.status == 204
      response.parsed.fetch('data')
    rescue OAuth2::Error => e
      raise Error.from_response(e.response)
    end

    def paginated(path, params = {})
      page = 1

      Enumerator.new do |yielder|
        loop do
          response = token.get(path, params: params.merge(page: page)).parsed
          response['data'].each { |item| yielder << item }
          break if response['_links']['next'].nil?
          page += 1
        end
      end
    rescue OAuth2::Error => e
      raise Error.from_response(e.response)
    end

  end
end
