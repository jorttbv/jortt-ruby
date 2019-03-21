module Jortt
  ##
  # Request error class, has a hash with the error response when possible
  class Error < StandardError
    attr_reader :errors

    def initialize(message, response)
      if response.code == 400
        json = JSON.parse(response.body)
        @errors = json["errors"] if json.key?("errors")
      end
    end
  end
end
