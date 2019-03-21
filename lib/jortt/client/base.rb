module Jortt # :nodoc:
  class Client # :nodoc:

    ##
    # This class is the base class for all sub clients
    class Base
    private

      def with_valid_response(&block)
        block.call
      rescue RestClient::Exception => error
        raise Jortt::Error.new(error.message, error.response)
      end

      def with_valid_json(&block)
        with_valid_response do
          response = block.call
          JSON.parse(response.body)
        end
      end
    end
  end
end
