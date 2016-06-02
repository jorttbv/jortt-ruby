# encoding: UTF-8
require 'rest-client'

module Jortt # :nodoc:
  class Client # :nodoc:

    class Invoice

      def initialize(config, id)
        @config = config
        @id = id
      end

      def send_invoice(args = {})
        resource = RestClient::Resource.new(
          "#{config.base_url}/invoices/id/#{@id}/send",
          user: config.app_name,
          password: config.api_key,
        )
        resource.post(JSON.generate(args)) do |response|
          JSON.parse(response.body)
        end
      end

      private
      attr_reader :config, :id
    end

  end
end
