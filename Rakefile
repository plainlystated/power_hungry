namespace :db do
  desc "Drop and recreate database"
  task :redo do
    require 'lib/wattcher_network/database'
    `psql -U postgres -c "drop database #{WattcherNetwork::Database::DB_NAME}"`
    `psql -U postgres -c "create database #{WattcherNetwork::Database::DB_NAME}"`
    WattcherNetwork::Database.connect
    WattcherNetwork::Database.migrate!
  end
end

namespace :wattcher_network do
  desc "Run, with lots of debug output"
  task :debug do
    require 'wattcher_network'
    wattcher = WattcherNetwork.new
    wattcher.debug
  end

  desc "Run the collector"
  task :run do
    require 'wattcher_network'
    wattcher = WattcherNetwork.new
    wattcher.run
  end
end
