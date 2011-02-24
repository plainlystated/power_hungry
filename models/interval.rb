class Interval
  include DataMapper::Resource

  property :id,              Serial

  property :interval_length, Integer
  property :watt_hours,      Float
  property :average_watts,   Float

  property :created_at,      DateTime, :default => lambda { DateTime.now }
  property :updated_at,      DateTime, :default => lambda { DateTime.now }
end
