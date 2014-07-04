require 'stargate'
Rails.configuration.stargate_connection = Stargate::Client.new(Rails.configuration.stargate_url)
