# frozen_string_literal: true
# frozen_string_literal: true

module Jortt # :nodoc:
  class Client # :nodoc:
    class Base
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def make_path(resource_path)
        path = !resource_path.start_with?('/') && !client.base_path.end_with?('/') ? "/#{resource_path}" : resource_path
        "#{client.base_path}#{path}"
      end
    end
  end
end
