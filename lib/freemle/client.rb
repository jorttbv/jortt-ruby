require "freemle/client/version"
require "freemle/resource"

module Freemle
  class Client
    BASE_URL = "https://www.freemle.com/api"

    attr_accessor :base_url, :app_name, :api_key

    def initialize(opts)
      self.base_url = opts.fetch(:base_url, BASE_URL)
      self.app_name = opts.fetch(:app_name)
      self.api_key = opts.fetch(:api_key)
    end

    def customers
      @customers ||= Freemle::Resource.new(self, :customer, :customers)
    end

    def invoices
      @invoices ||= Freemle::Resource.new(self, :invoice, :invoices)
    end
  end
end
