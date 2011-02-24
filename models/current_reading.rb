class CurrentReading
  include DataMapper::Resource

  property :id,         Serial
  property :serialized, String
end
