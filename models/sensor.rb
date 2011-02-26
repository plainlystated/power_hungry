class Sensor
  include DataMapper::Resource

  property :slug,    String, :key => true, :default => lambda {|s, dm| s.name.downcase.sub(/\W/, '') }
  property :address, Integer
  property :name,    String

  has n, :intervals
  has 1, :current_reading

  property :created_at,   DateTime, :default => lambda { DateTime.now }
  property :updated_at,   DateTime, :default => lambda { DateTime.now }
  property :imported_at, DateTime

  def to_s
    name || "Sensor #{address}"
  end
end
