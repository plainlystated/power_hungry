class CurrentReading
  include DataMapper::Resource

  property :sensor_slug,   String, :key => true
  property :amperage_data, Json
  property :voltage_data,  Json
  property :wattage_data,  Json
  property :amperage_avg,  Float
  property :voltage_avg,   Float
  property :wattage_avg,   Float
  property :watt_hours,    Float
  belongs_to :sensor

  property :created_at, DateTime, :default => lambda { DateTime.now }
  property :updated_at, DateTime, :default => lambda { DateTime.now }
  property :imported_at, DateTime
end
