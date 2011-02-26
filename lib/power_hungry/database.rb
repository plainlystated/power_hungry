require 'dm-core'
require 'dm-migrations'
require 'dm-types'

require 'models/current_reading'
require 'models/interval'
require 'models/sensor'

class PowerHungry
  module Database
    def self.connect(debug = false)
      DataMapper::Logger.new($stdout, :debug) if debug

      login = PowerHungry::Config.database_login
      password = PowerHungry::Config.database_password
      server = PowerHungry::Config.database_server
      db = PowerHungry::Config.database_name
      DataMapper.setup(:default, "postgres://#{login}:#{password}@#{server}/#{db}")
      DataMapper.finalize
    end

    def self.migrate!
      DataMapper.auto_upgrade!
    end
  end
end
