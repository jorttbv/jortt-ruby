# encoding: UTF-8
require 'freemle/client'
require 'freemle/client/version'

##
# This module contains everything needed to setup a connection to the Freemle
# API. It's only method returns a configured Freemle::Client.
module Freemle

  # Convenient way to initialize a freemle client.
  #
  # @see {Freemle::Client.initialize}
  #
  # @return [ Freemle::Client ] a new freemle client instance
  #
  # @since 1.0.1
  def client(*args)
    Freemle::Client.new(*args)
  end
  module_function :client

end
