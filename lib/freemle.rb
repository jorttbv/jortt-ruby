require 'freemle/client'
require 'freemle/client/version'

module Freemle

  # Convenient way to initialize a freemle client.
  #
  # @see {Freemle::Client.initialize}
  #
  # @since 1.0.1
  def client(*args)
    Freemle::Client.new(*args)
  end
  module_function :client

end
