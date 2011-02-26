require 'dm-core'
require 'dm-migrations'
require 'dm-types'

require 'lib/power_hungry/config'

require 'models/current_reading'
require 'models/interval'
require 'models/sensor'

PowerHungry::Config.init

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

    def self.connect_external
      login = PowerHungry::Config.database_external_login
      password = PowerHungry::Config.database_external_password
      server = PowerHungry::Config.database_external_server
      db = PowerHungry::Config.database_external_name
      DataMapper.setup(:external, "postgres://#{login}:#{password}@#{server}/#{db}")
    end

    def self.migrate!
      DataMapper.auto_upgrade!
    end
  end
end
