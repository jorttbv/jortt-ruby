module Jortt # :nodoc:
  class Client # :nodoc:
    class ResponseError < StandardError # :nodoc:
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
  end
end
