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


