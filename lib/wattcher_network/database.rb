require 'dm-core'
require 'dm-migrations'

require 'models/current_reading'

class WattcherNetwork
  module Database
    SERVER = "localhost"
    DB_NAME = "wattcher_network"
    USERNAME = "wattcher_network"
    PASSWORD = "Ed_HtnszGhr4Ac5h4kGFV-cy_mU"

    def self.connect
      DataMapper::Logger.new($stdout, :debug)
      DataMapper.setup(:default, "postgres://#{USERNAME}:#{PASSWORD}@#{SERVER}/#{DB_NAME}")
      DataMapper.finalize
    end

    def self.migrate!
      DataMapper.auto_upgrade!
    end
  end
end
