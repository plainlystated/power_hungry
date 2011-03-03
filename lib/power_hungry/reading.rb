require 'json'

class PowerHungry
  class Reading
    module Sensors
      CURRENT = 4
      VOLTAGE = 0
    end

    MAINSVPP = 170 * 2  # +-170V is what 120Vrms ends up being (= 120*2sqrt(2))
    CURRENT_NORM = 15.5 # Conversion to amps from ADC

    VrefCalibration = [
      :collector,  # This address is the collector's
      497,         # Calibration for sensor #1
      469,         # Sensor 2
      470          # Sensor 3
    ]

    # sampling at 1khz, so 16.6 samples per period.  Considering the first 17 samples should be close enough
    SAMPLES_PER_PERIOD = 17.0
    SAMPLE_INTERVAL = 2 # Seconds

    attr_reader :amperage_data, :voltage_data, :wattage_data, :sensor

    def initialize(packet, debug=false)
      @voltage_data = _parse_voltage_data(packet)
      @amperage_data = _parse_amperage_data(packet)
      @wattage_data = _calculate_wattage_data(@voltage_data, @amperage_data)
      unless @sensor = Sensor.first(:address => packet.address)
        @sensor = Sensor.create!(:address => packet.address)
      end

      puts "Averages: #{averages.inspect}" if debug
      save
    end

    def save
      params = {
        :voltage_data => @voltage_data,
        :amperage_data => @amperage_data,
        :wattage_data => @wattage_data,
        :voltage_avg => averages[:volts],
        :amperage_avg => averages[:amps],
        :wattage_avg => averages[:watts],
        :watt_hours => watt_hours
      }
      if @sensor.current_reading
        @sensor.current_reading.update!(params.merge(:updated_at => DateTime.now))
      else
        CurrentReading.create!(params.merge(:sensor => @sensor))
      end
    end

    def averages
      return @averages if @averages

      @averages = {}
      {
        :amps => @amperage_data,
        :volts => @voltage_data,
        :watts => @wattage_data
      }.each do |key, data|
        one_cycle = data[0, SAMPLES_PER_PERIOD]
        @averages[key] = one_cycle.inject(0.0) { |sum, val| sum + val.abs } / SAMPLES_PER_PERIOD
      end
      @averages
    end

    def watt_hours
      (averages[:watts] * SAMPLE_INTERVAL) / (60 * 60) # watts used over interval, divided by 1 hour
    end

    def to_s
      str = ""
      str += @voltage_data.inspect + "\n"
      str += @amperage_data.inspect + "\n"

      @voltage_data.size.times do |i|
        volts = "%7.2f" % @voltage_data[i]
        amps = "%6.2f" % @amperage_data[i]
        watts = "%7.2f" % @wattage_data[i]
        str += "#{volts} * #{amps} = #{watts}\n"
      end
      str
    end

    def _parse_amperage_data(packet)
      data = packet.analog_samples.map { |sensor_readings| sensor_readings[Sensors::CURRENT] }

      offset = VrefCalibration[packet.address]
      data.map do |amp|
        a = amp - offset
        a / CURRENT_NORM
      end
    end

    def _parse_voltage_data(packet)
      data = packet.analog_samples.map { |sensor_readings| sensor_readings[Sensors::VOLTAGE] }

      avg = data.inject(0.0) { |result, volt| result + volt } / data.size
      vpp = data.max - data.min

      data.map do |voltage|
        # Remove DC bias
        v = voltage - avg
        (v * MAINSVPP) / vpp
      end
    end

    def _calculate_wattage_data(voltage_data, amperage_data)
      voltage_data.zip(amperage_data).map { |v, a| v * a }
    end
  end
end
