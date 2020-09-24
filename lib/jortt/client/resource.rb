require 'oauth2'

module Jortt # :nodoc:
  class Client # :nodoc:
    class ResponseError < StandardError
      attr_reader :response, :code, :key, :message, :details

      def initialize(response)
        @code = response.parsed.dig('error', 'code')
        @key = response.parsed.dig('error', 'key')
        @message = response.parsed.dig('error', 'message')
        @details = response.parsed.dig('error', 'details')

        super(error_message)
      end

      def error_message
        [message].tap do |m|
          details.each do |detail|
            m << "#{detail['param']} #{detail['message']}"
          end
        end.join("\n")
      end
    end

    class Resource # :nodoc:
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      private

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
        raise ResponseError.new(e.response)
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
        raise ResponseError.new(e.response)
      end
    end
  end
end
