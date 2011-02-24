namespace :db do
  desc "drop and recreate database"
  task :redo do
    require 'lib/wattcher_network/database'
    `psql -U postgres -c "drop database #{WattcherNetwork::Database::DB_NAME}"`
    `psql -U postgres -c "create database #{WattcherNetwork::Database::DB_NAME}"`
    WattcherNetwork::Database.connect
    WattcherNetwork::Database.migrate!
  end
end
