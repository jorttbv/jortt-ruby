# frozen_string_literal: true

require 'oauth2'

require 'jortt/client/error'
require 'jortt/client/customers'
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
    # @see https://developer.jortt.nl/#authorization-code-grant-type documentation on Authorization code grant type
    #
    # @param [String] id Your Client ID
    # @param [String] secret Your Client Secret
    # @param [Hash] opts Options for the client
    # @option opts [String] :oauth_provider_url The base URL to the OAuth provider
    # @option opts [String] :site The base URL to the API
    # @option opts [String] :scope The list of required scopes
    # @option opts [String] :access_token Authorized Access Token to the API
    # @option opts [String] :refresh_token Refresh Token to the API
    # @option opts [String] :expires_at The expiration time as an integer number of seconds since the Epoch
    # @return [ Jortt::Client ]
    #
    # @since 1.0.0
    def initialize(id, secret, opts = {})
      client = oauth2_client(id, secret, opts)

      if opts[:access_token]
        # Use authorization code grant type
        @token = OAuth2::AccessToken.from_hash(
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
        @token = client.client_credentials.get_token(
          scope: opts[:scope] || 'invoices:read invoices:write customers:read customers:write organizations:read',
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

    # Access the organizations resource.
    #
    # @example
    #   client.organizations
    #
    # @return [ Jortt::Client::Organizations ] entry to the organizations resource.
    #
    def organizations
      Jortt::Client::Organizations.new(self)
    end

    # Access the tradenames resource.
    #
    # @example
    #   client.tradenames
    #
    # @return [ Jortt::Client::Organizations ] entry to the organizations resource.
    #
    def tradenames
      Jortt::Client::Tradenames.new(self)
    end

    def get(path, params = {})
      handle_response { token.get(path, params: params, snaky: false) }
    end

    def post(path, payload = {})
      handle_response { token.post(path, body: payload.to_json, snaky: false, headers: { "Content-Type" => "application/json" }) }
    end

    def put(path, payload = {})
      handle_response { token.put(path, body: payload.to_json, snaky: false, headers: { "Content-Type" => "application/json" }) }
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
