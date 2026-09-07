# frozen_string_literal: true

module Jortt # :nodoc:
  class Client # :nodoc:
    class Error < StandardError # :nodoc:
      def self.from_response(response)
        if (400...500).include? response.status
          error = response.parsed['error'] if response.parsed.is_a?(Hash)
          # A few endpoints put a bare message string under `error` rather than the
          # usual object, e.g. POST /v3/expenses/id/{id}/receipt on a duplicate receipt.
          error = {'code' => response.status, 'message' => error} unless error.is_a?(Hash)

          JorttError.new(error['code'], error['key'], error['message'], error['details'])
        elsif response.status >= 500
          ServerError.new(response.status, response.response.reason_phrase, response.body)
        end
      end
    end

    class JorttError < Error # :nodoc:
      attr_reader :response, :code, :key, :message, :details

      def initialize(code, key, message, details)
        @code = code
        @key = key
        @message = message
        @details = details || []

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

    class ServerError < Error
      attr_reader :status, :message, :body

      def initialize(status, message, body)
        super(message)
        @status = status
        @message = message
        @body = body
      end

      def error_message
        "#{status} #{message}"
      end
    end
  end
end
