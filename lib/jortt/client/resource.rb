require 'oauth2'

module Jortt # :nodoc:
  class Client # :nodoc:
    class Resource # :nodoc:
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      private

      def get(path, params = {})
        handle_response token.get(path, params: params)
      end

      def post(path, params = {})
        handle_response token.post(path, params: params)
      end

      def put(path, params = {})
        handle_response token.put(path, params: params)
      end

      def handle_response(response)
        return true if response.status == 204
        response.parsed.fetch('data')
      end
    end
  end
end
