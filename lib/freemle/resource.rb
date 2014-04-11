require 'rest-client'

module Freemle
  class Resource < Struct.new(:config, :singular, :plural)

    def search(query, &block)
      block = default_handler unless block_given?
      request.get(params: query, &block)
    end

    def create(payload, &block)
      block = default_handler unless block_given?
      request.post(json.generate({singular => payload}), &block)
    end

  private

    def default_handler
      Proc.new { |response| json.parse(response.body) }
    end

    def request
      RestClient::Resource.new(
        "#{config.base_url}/#{plural}",
        user: config.app_name,
        password: config.api_key
      )
    end

    def json
      return @json if @json
      require 'json'
      @json = JSON
    end

  end
end
