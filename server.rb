require 'rubygems'
require 'sinatra'
require 'lib/power_hungry/config'
require 'lib/power_hungry/database'

PowerHungry::Config.init
PowerHungry::Database.connect

helpers do
  def amps(sensor)
    _data_to_timeless_pairs(sensor.current_reading.amperage_data)
  end

  def amps_bounds(sensor)
    bound = 0
    if sensor.current_reading.amperage_data.min.abs > sensor.current_reading.amperage_data.max
      bound = sensor.current_reading.amperage_data.min.abs
    else
      bound = sensor.current_reading.amperage_data.max
    end
    bound + (bound * 0.1)
  end

  def interval_points(intervals, method)
    intervals.map do |interval|
      [_to_timestamp(interval.updated_at), interval.send(method)]
    end
  end

  def voltages(sensor)
    _data_to_timeless_pairs(sensor.current_reading.voltage_data)
  end

  def watt_hours(sensor_intervals)
    watt_hours = []
    cummulative_watt_hours = 0

    all_timestamps = sensor_intervals.map { |sensor, intervals| intervals.map { |interval| _to_timestamp(interval.updated_at) } }.flatten.uniq.sort
    all_timestamps.each do |timestamp|
      timestamp_watt_hours = 0

      sensor_intervals.each do |sensor, intervals|
        if interval = intervals.detect { |i| _to_timestamp(i.updated_at) == timestamp }
          interval_watt_hours = interval.watts * interval.interval_length / (60.0 * 60)
          timestamp_watt_hours += interval_watt_hours
        end
      end

      cummulative_watt_hours += timestamp_watt_hours
      watt_hours << [timestamp, cummulative_watt_hours]
    end
    watt_hours
  end

  def watts(sensor)
    _data_to_timeless_pairs(sensor.current_reading.wattage_data)
  end

  def _data_to_timeless_pairs(data)
    (0..data.size-1).map do |i|
      [i, data[i]]
    end
  end

  def _to_timestamp(datetime)
    time = Time.parse(datetime.to_s)
    time = time + (datetime.offset * 24 * 60 * 60)
    time.to_i * 1000
  end
end

get '/' do
  @past_hour = {}
  @past_day = {}
  @sensors = Sensor.all
  @sensors.each do |sensor|
    @past_hour[sensor] = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60))
    @past_day[sensor] = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60*24))
  end

  erb :graph
end


