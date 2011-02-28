namespace :db do
  desc "Drop and recreate database"
  task :redo do
    require 'lib/power_hungry/database'
    `sudo -u postgres psql -c "drop database #{PowerHungry::Config.database_name}"`
    `sudo -u postgres psql -c "create database #{PowerHungry::Config.database_name}"`
    PowerHungry::Database.migrate!
    Rake::Task["power_hungry:name_sensors"].invoke
  end

  desc "Migrate the database"
  task :migrate do
    require 'lib/power_hungry/database'
    PowerHungry::Database.migrate!
  end

  desc "Push updates to external (web) server"
  task :update_web_server do
    puts "Updating remote database at #{Time.now}"
    require 'lib/power_hungry/data_vacuum'

    PowerHungry::DataVacuum.update_external
  end
end

namespace :power_hungry do
  desc "Run, with lots of debug output"
  task :debug do
    require 'power_hungry'
    power_hungry = PowerHungry.new
    power_hungry.debug
  end

  desc "Run the collector"
  task :run do
    require 'power_hungry'
    power_hungry = PowerHungry.new
    power_hungry.run
  end

  desc "Update sensor names"
  task :name_sensors do
    require 'power_hungry'
    [
      [1, "Media Center"],
      [3, "Kitchen Appliances"]
    ].each do |address, name|
      if sensor = Sensor.first(:address => address)
        sensor.update!(:name => name) unless sensor.name == name
      else
        Sensor.create!(:address => address, :name => name)
      end
    end
  end
end
