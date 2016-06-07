# encoding: UTF-8
require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # Exposes the operations available for a single invoice.
    #
    # @see { Jortt::Client.invoice }
    class Invoice

      def initialize(config, id)
        @config = config
        @id = id
      end

      ##
      # Sends an Invoice using the POST /invoices/id/:invoice_id/send endpoint.
      #
      # @example
      #   Jortt::Client.invoice(:invoice_id).send(
      #     mail_data: {
      #       to: 'ben@jortt.nl', # optional
      #       subject: 'Thank you for your assignment', # optional
      #       body: 'I hereby send you the invoice', # optional
      #     },
      #     invoice_date: Date.today, # optional
      #     payment_term: 7, # optional
      #     language: 'nl', # optional
      #     send_method: 'email', # optional
      #   )
      def send_invoice(payload = {})
        resource = RestClient::Resource.new(
          "#{config.base_url}/invoices/id/#{id}/send",
          user: config.app_name,
          password: config.api_key,
        )
        resource.post(JSON.generate(payload)) do |response|
          JSON.parse(response.body)
        end
      end

    private

      attr_reader :config, :id
    end

  end
end
