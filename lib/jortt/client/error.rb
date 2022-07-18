# frozen_string_literal: true

module Jortt # :nodoc:
  class Client # :nodoc:
    class Error < StandardError # :nodoc:
      attr_reader :response, :code, :key, :message, :details

      def self.from_response(response)
        Error.new(
          response.parsed.dig('error', 'code'),
          response.parsed.dig('error', 'key'),
          response.parsed.dig('error', 'message'),
          response.parsed.dig('error', 'details'),
        )
      end

      def initialize(code, key, message, details)
        @code = code
        @key = key
        @message = message
        @details = details

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
