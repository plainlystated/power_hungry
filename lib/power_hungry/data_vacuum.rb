class PowerHungry
  class DataVacuum
    def self.update_external
      update_sensors
      update_current_readings
      update_intervals
    end

    def self.update_current_readings
      puts "Updating Current Readings"
      CurrentReading.all.each do |sensor_reading|
        params = {
          :amperage_avg => sensor_reading.amperage_avg,
          :voltage_avg => sensor_reading.voltage_avg,
          :wattage_avg => sensor_reading.wattage_avg,
          :amperage_data => sensor_reading.amperage_data,
          :voltage_data => sensor_reading.voltage_data,
          :wattage_data => sensor_reading.wattage_data,
          :watt_hours => sensor_reading.watt_hours,
          :created_at => sensor_reading.created_at,
          :updated_at => sensor_reading.updated_at,
          :imported_at => DateTime.now
        }
        DataMapper.repository(:external) do
          if ext_reading = CurrentReading.first(:sensor_slug => sensor_reading.sensor_slug)
            ext_reading.update!(params)
          else
            CurrentReading.create!(params.merge(:sensor_slug => sensor_reading.sensor_slug))
          end
        end
      end
    end

    def self.update_intervals
      puts "Updating Intervals"
      last_export = DataMapper.repository(:external) do
        Interval.first(:order => [ :created_at.desc ]).try(:created_at)
      end

      intervals = last_export.nil? ? Interval.all : Interval.all(:created_at.gt => last_export)
      puts " - sending #{intervals.length} new records"
      intervals.each do |interval|
        params = {
          :interval_length => interval.interval_length,
          :watt_hours      => interval.watt_hours,
          :sensor_slug     => interval.sensor_slug,
          :created_at      => interval.created_at,
          :updated_at      => interval.updated_at,
          :imported_at     => DateTime.now
        }
        DataMapper.repository(:external) { Interval.create!(params) }
      end
    end

    def self.update_sensors
      puts "Updating Sensors"
      Sensor.all.each do |sensor|
        params = {
          :name => sensor.name,
          :address => sensor.address,
          :created_at => sensor.created_at,
          :updated_at => sensor.updated_at,
          :imported_at => DateTime.now
        }
        DataMapper.repository(:external) do
          if ext_sensor = Sensor.first(:slug => sensor.slug)
            ext_sensor.update!(params)
          else
            Sensor.create!(params.merge(:slug => sensor.slug))
          end
        end
      end
    end
  end
end

PowerHungry::Database.connect_external
