class Interval
  include DataMapper::Resource

  property :id,              Serial

  property :interval_length, Integer
  property :watt_hours,      Float

  belongs_to :sensor

  property :created_at,      DateTime, :default => lambda { DateTime.now }
  property :updated_at,      DateTime, :default => lambda { DateTime.now }
  property :imported_at,    DateTime
end
