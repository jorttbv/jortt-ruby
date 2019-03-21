require 'jortt/error'
require 'jortt/client'
require 'jortt/client/version'

##
# This module contains everything needed to setup a connection to the Jortt
# API. It's only method returns a configured Jortt::Client.
module Jortt

  # Convenient way to initialize a jortt client.
  #
  # @see {Jortt::Client.initialize}
  #
  # @return [ Jortt::Client ] a new jortt client instance
  #
  # @since 1.0.1
  def client(*args)
    Jortt::Client.new(*args)
  end
  module_function :client

end
