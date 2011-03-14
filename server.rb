require 'rubygems'
require 'sinatra'
require 'lib/power_hungry/config'
require 'lib/power_hungry/database'

PowerHungry::Config.init
PowerHungry::Database.connect

helpers do
  def amps(sensor)
    _data_to_faketime_pairs(sensor.current_reading.updated_at, sensor.current_reading.amperage_data)
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
    _data_to_faketime_pairs(sensor.current_reading.updated_at, sensor.current_reading.voltage_data)
  end

  def watt_hours(sensor_intervals)
    watt_hours = []
    cummulative_watt_hours = 0

    timestamp_intervals = sensor_intervals.inject({}) do |grouped_intervals, (sensor, intervals)|
      intervals.each do |interval|
        grouped_intervals[interval.updated_at] ||= []
        grouped_intervals[interval.updated_at] << interval
      end

      grouped_intervals
    end

    all_timestamps = timestamp_intervals.keys.sort

    all_timestamps.each do |timestamp|
      timestamp_watt_hours = 0

      timestamp_watt_hours = timestamp_intervals[timestamp].inject(0) do |watt_hours_sum, interval|
        interval_watt_hours = interval.watts * interval.interval_length / (60.0 * 60)
        watt_hours_sum + interval_watt_hours
      end

      cummulative_watt_hours += timestamp_watt_hours
      watt_hours << [_to_timestamp(timestamp), cummulative_watt_hours]
    end

    watt_hours
  end

  def watts(sensor)
    _data_to_faketime_pairs(sensor.current_reading.updated_at, sensor.current_reading.wattage_data)
  end

  def _data_to_faketime_pairs(start, data)
    pairs = []
    start_timestamp = _to_timestamp(start)

    data.each_with_index do |value, i|
      pairs << [start_timestamp + i, value]
    end

    pairs
  end

  def _to_timestamp(datetime)
    usec = (datetime.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
    time = Time.gm(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.min,
              datetime.sec, usec)

    time.to_i * 1000
  end
end

get '/' do
  @past_day = {}
  @past_week = {}
  @sensors = Sensor.all
  @sensors.each do |sensor|
    @past_day[sensor] = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60*24))
    @past_week[sensor] = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60*24 * 30))
  end

  erb :graph
end


