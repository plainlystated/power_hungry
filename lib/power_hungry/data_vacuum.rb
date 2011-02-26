class PowerHungry
  class DataVacuum
    def self.update_external
      update_sensors
      update_current_reading
    end

    def self.update_current_reading
      CurrentReading.all.each do |sensor_reading|
        params = {
          :amperage_avg => sensor_reading.amperage_avg,
          :voltage_avg => sensor_reading.voltage_avg,
          :wattage_avg => sensor_reading.wattage_avg,
          :watt_hours => sensor_reading.watt_hours,
          :created_at => sensor_reading.created_at,
          :updated_at => sensor_reading.updated_at,
          :imported_at => DateTime.now
        }
        DataMapper.repository(:external) do
          if ext_reading = CurrentReading.find(:sensor_slug => sensor_reading.sensor_slug)
            ext_reading.update!(params)
          else
            CurrentReading.create!(params.merge(:sensor_slug => sensor_reading.sensor_slug)
          end
        end
      end
    end

    def self.update_sensors
      Sensor.all.each do |sensor|
        params = {
          :name => sensor.name,
          :address => sensor.address,
          :created_at => sensor.created_at,
          :updated_at => sensor.updated_at,
          :imported_at => DateTime.now
        }
        DataMapper.repository(:external) do
          if ext_sensor = Sensor.find(:slug => sensor.sensor_slug)
            ext_sensor.update!(params)
          else
            Sensor.create!(params.merge(:slug => sensor.sensor_slug)
          end
        end
      end
    end
  end
end

PowerHungry::Database.connect_external
