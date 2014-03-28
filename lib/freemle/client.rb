require "freemle/client/version"
require "active_support/all"
require "httpclient"

module Freemle
  class Client
    class << self
      attr_accessor :base_url, :app_name, :api_key
    end

    # Finds customers in Freemle and returns them as a list of hashes. Each hash represents a customer.
    #
    # Raises Freemle::BadRequest when validation errors occur.
    # Raises Freemle::UnauthorizedError when app_name and api_key are not properly set.
    # Raises Freemle::ServerError if something goes wrong on the server for any other reason.
    def self.find_customers(company_name)
      client = get_client
      response = client.get "#{base_url}/customers", {company_name: company_name}, {Authorization: "Basic #{get_auth_header}"}
      handle_response(response, {200 => lambda { |response| from_json(response.body)["customers"] }})
    end

    # Creates an invoice in Freemle with the given values. Returns the unique ID of the created invoice.
    #
    # Raises Freemle::BadRequest when validation errors occur.
    # Raises Freemle::UnauthorizedError when app_name and api_key are not properly set.
    # Raises Freemle::ServerError if something goes wrong on the server for any other reason.
    def self.create_invoice(invoice)
      post "/invoices", invoice: invoice do |body_as_hash|
        body_as_hash["invoice_id"]
      end
    end

    # Creates a customer in Freemle with the given values. Returns the unique ID of the created invoice.
    #
    # Raises Freemle::BadRequest when validation errors occur.
    # Raises Freemle::UnauthorizedError when app_name and api_key are not properly set.
    # Raises Freemle::ServerError if something goes wrong on the server for any other reason.
    def self.create_customer(customer)
      post "/customers", customer: customer do |body_as_hash|
        body_as_hash["customer_id"]
      end
    end

  private

    def self.post(url, body, &block)
      client = get_client
      response = client.post "#{base_url}#{url}", body.to_json, {Authorization: "Basic #{get_auth_header}", 'Content-Type' => 'application/json'}
      body_as_hash = handle_response(response, {201 => lambda { |response| from_json(response.body) }})
      yield body_as_hash
    end

    def self.get_client
      HTTPClient.new
    end

    def self.get_auth_header
      Base64.encode64("#{app_name}:#{api_key}").delete("\r\n")
    end

    def self.handle_response(response, status_handlers = {})
      case response.status
        when 400 then
          raise BadRequest.new(from_json(response.body)["errors"])
        when 401 then
          raise UnauthorizedError
        when 500 then
          raise ServerError
        else
          if status_handlers[response.status].present?
            status_handlers[response.status].call(response)
          else
            raise UnsupportedStatusCode.new(response.status)
          end
      end
    end

    def self.from_json(body)
      ActiveSupport::JSON.decode(body)
    end

    class Error < RuntimeError
    end

    class UnsupportedStatusCode < Error
      attr_reader :status_code

      def initialize(status_code)
        @status_code = status_code
      end

      def to_s
        @status_code.to_s
      end
    end

    class UnauthorizedError < Error
    end

    class ServerError < Error
    end

    class BadRequest < Error
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end

      def to_s
        @errors.to_s
      end
    end
  end
end
