class Sensor
  include DataMapper::Resource

  property :id,   Serial
  property :address, Integer
  property :name, String

  has n, :intervals
  has 1, :current_reading

  property :created_at, DateTime, :default => lambda { DateTime.now }
  property :updated_at, DateTime, :default => lambda { DateTime.now }

  def to_s
    name || "Sensor #{address}"
  end
end
