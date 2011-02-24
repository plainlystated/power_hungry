require 'dm-core'
require 'dm-migrations'
require 'dm-types'

require 'models/current_reading'
require 'models/interval'

class WattcherNetwork
  module Database
    SERVER = "localhost"
    DB_NAME = "wattcher_network"
    USERNAME = "wattcher_network"
    PASSWORD = "Ed_HtnszGhr4Ac5h4kGFV-cy_mU"

    def self.connect(debug = false)
      DataMapper::Logger.new($stdout, :debug) if debug
      DataMapper.setup(:default, "postgres://#{USERNAME}:#{PASSWORD}@#{SERVER}/#{DB_NAME}")
      DataMapper.finalize
    end

    def self.migrate!
      DataMapper.auto_upgrade!
    end
  end
end
