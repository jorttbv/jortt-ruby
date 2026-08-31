# frozen_string_literal: true

require 'oauth2'

require 'jortt/client/error'
require 'jortt/client/customers'
require 'jortt/client/expenses'
require 'jortt/client/invoices'
require 'jortt/client/ledger_accounts'
require 'jortt/client/organizations'
require 'jortt/client/tradenames'

module Jortt
  ##
  # This class is the main interface used to communicate with the Jortt API.
  # It is by the {Jortt} module to create configured instances.
  class Client
    SITE = 'https://api.jortt.nl'
    OAUTH_PROVIDER_URL = 'https://app.jortt.nl/oauth-provider/oauth'
    # Jortt rejects a token request asking for scopes the application was not registered
    # with, so adding a scope here breaks integrations that have not registered it.
    DEFAULT_SCOPE = %w[
      invoices:read
      invoices:write
      customers:read
      customers:write
      organizations:read
      expenses:read
    ].join(' ').freeze

    attr_accessor :token, :base_path

    # Initialize a Jortt client with client credentials or authorization code.
    #
    # @example with client credentials
    #   Jortt::Client.new(
    #     "my-client-id",
    #     "my-client-secret"
    #   )
    #
    # @example with authorization code
    #   Jortt::Client.new(
    #     "client-id",
    #     "client-secret",
    #     scope: "invoices:read customers:read",
    #     access_token: "access-token",
    #     refresh_token: "refresh-token",
    #     expires_at: 1657896798
    #   )
    # @see https://developer.jortt.nl/#intro-authorization-code-grant-type
    #   documentation on Authorization code grant type
    #
    # @param [String] id Your Client ID
    # @param [String] secret Your Client Secret
    # @param [Hash] opts Options for the client
    # @option opts [String] :oauth_provider_url The base URL to the OAuth provider
    # @option opts [String] :site The base URL to the API
    # @option opts [String] :scope The list of required scopes, defaults to {DEFAULT_SCOPE}
    # @option opts [String] :access_token Authorized Access Token to the API
    # @option opts [String] :refresh_token Refresh Token to the API
    # @option opts [String] :expires_at The expiration time as an integer number of seconds since the Epoch
    # @return [ Jortt::Client ]
    #
    # @since 1.0.0
    def initialize(id, secret, opts = {})
      client = oauth2_client(id, secret, opts)

      @token = if opts[:access_token]
                 # Use authorization code grant type
                 OAuth2::AccessToken.from_hash(
                   client,
                   {
                     scope: opts[:scope],
                     access_token: opts[:access_token],
                     refresh_token: opts[:refresh_token],
                     expires_at: opts[:expires_at],
                   },
                 )
               else
                 # Use client credentials grant type
                 client.client_credentials.get_token(
                   scope: opts[:scope] || DEFAULT_SCOPE,
                 )
               end
    end

    def oauth2_client(client_id, client_secret, opts = {})
      oauth_provider_url = opts[:oauth_provider_url] || OAUTH_PROVIDER_URL
      site = opts[:site] || SITE
      site_uri = URI(site)
      site_host = [site_uri.scheme, [site_uri.host, site_uri.port].join(':')].join('://')
      @base_path = site_uri.path

      OAuth2::Client.new(
        client_id,
        client_secret,
        site: site_host,
        token_url: "#{oauth_provider_url}/token",
        authorize_url: "#{oauth_provider_url}/authorize",
        auth_scheme: :basic_auth,
      )
    end

    # Access the customer resource to perform operations.
    #
    # @example
    #   client.customers
    #
    # @return [ Jortt::Client::Customers ] entry to the customer resource.
    #
    # @see https://developer.jortt.nl/#tag-v3-customers
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
    # @see https://developer.jortt.nl/#tag-v3-invoices
    # @since 1.0.0
    def invoices
      @invoices ||= Jortt::Client::Invoices.new(self)
    end

    # Access the expenses resource to perform operations.
    #
    # @example
    #   client.expenses
    #
    # @return [ Jortt::Client::Expenses ] entry to the expenses resource.
    #
    # @see https://developer.jortt.nl/#tag-v3-expenses
    def expenses
      @expenses ||= Jortt::Client::Expenses.new(self)
    end

    # Access the ledger_accounts resource.
    #
    # @example
    #   client.ledger_accounts
    #
    # @return [ Jortt::Client::LedgerAccounts ] entry to the leger_accounts resource.
    #
    # @see https://developer.jortt.nl/#tag-v3-ledger-accounts
    # @since 5.0.0
    def ledger_accounts
      Jortt::Client::LedgerAccounts.new(self)
    end

    # Access the organizations resource.
    #
    # @example
    #   client.organizations
    #
    # @return [ Jortt::Client::Organizations ] entry to the organizations resource.
    #
    # @see https://developer.jortt.nl/#tag-v3-organizations
    def organizations
      Jortt::Client::Organizations.new(self)
    end

    # Access the tradenames resource.
    #
    # @example
    #   client.tradenames
    #
    # @return [ Jortt::Client::Tradenames ] entry to the tradenames resource.
    #
    # @see https://developer.jortt.nl/#tag-v3-tradenames
    def tradenames
      Jortt::Client::Tradenames.new(self)
    end

    def get(path, params = {})
      handle_response { token.get(path, params: params, snaky: false) }
    end

    def post(path, payload = {})
      handle_response do
        token.post(path, body: payload.to_json, snaky: false, headers: {'Content-Type' => 'application/json'})
      end
    end

    def put(path, payload = {})
      handle_response do
        token.put(path, body: payload.to_json, snaky: false, headers: {'Content-Type' => 'application/json'})
      end
    end

    def delete(path)
      handle_response { token.delete(path, snaky: false) }
    end

    def handle_response
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
