require 'rubygems'
require 'sinatra'
require 'lib/power_hungry/config'
require 'lib/power_hungry/database'
require 'active_support'

PowerHungry::Config.init
PowerHungry::Database.connect

DEBUG = true
NUM_INTERVALS = 500

class Cache
  @@cache = nil

  def self.empty?
    @@cache.nil?
  end

  def self.expired?
    @@expires_at < Time.now
  end

  def self.fetch(options = {})
    if empty? || expired?
      @@expires_at = Time.now + 20 # Prevent race condition

      @@cache = yield
      @@expires_at = options[:expires_at]
    end

    @@cache
  end

  def self.get(name)
    @@cache[name]
  end

  def self.set(name, value)
    @@empty = false
    @@cache[name] = value
  end
end

helpers do
  def amps(sensor)
    _data_to_faketime_pairs(_to_timestamp(sensor.current_reading.updated_at), sensor.current_reading.amperage_data)
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
      [interval[:updated_at], interval[method]]
    end
  end

  def voltages(sensor)
    _data_to_faketime_pairs(_to_timestamp(sensor.current_reading.updated_at), sensor.current_reading.voltage_data)
  end

  def downsample(intervals, num_samples)
    start = Time.now

    # factor = count / num_samples
    factor = intervals.size / num_samples
    factor = 1 if factor == 0

    downsampled = []
    intervals.in_groups_of(factor) do |group|
      next if group.last.nil? # only consider full sets

      updated_at = (_to_timestamp(group.first.updated_at) + _to_timestamp(group.last.updated_at)) / 2
      interval_length = _average(group, :interval_length)
      watts = _average(group, :watts)

      downsampled << {:interval_length => interval_length, :updated_at => updated_at, :watts => watts}
    end

    downsampled
  end

  def interval(data)
    {:interval_length => data[:interval_length], :updated_at => _to_timestamp(data[:updated_at]), :watts => data[:watts]}
  end

  def watt_hours(sensor_intervals)
    start = Time.now
    watt_hours = []
    cummulative_watt_hours = 0

    timestamp_intervals = sensor_intervals.inject({}) do |grouped_intervals, (sensor, intervals)|
      intervals.each do |interval|
        grouped_intervals[interval[:updated_at]] ||= []
        grouped_intervals[interval[:updated_at]] << interval
      end

      grouped_intervals
    end

    all_timestamps = timestamp_intervals.keys.sort

    all_timestamps.each do |timestamp|
      timestamp_watt_hours = 0

      timestamp_watt_hours = timestamp_intervals[timestamp].inject(0) do |watt_hours_sum, interval|
        interval_watt_hours = interval[:watts] * interval[:interval_length] / (60.0 * 60)
        watt_hours_sum + interval_watt_hours
      end

      cummulative_watt_hours += timestamp_watt_hours
      watt_hours << [timestamp, cummulative_watt_hours]
    end

    watt_hours
  end

  def watts(sensor)
    _data_to_faketime_pairs(_to_timestamp(sensor.current_reading.updated_at), sensor.current_reading.wattage_data)
  end

  def _average(set, attribute)
    set.inject(0.0) { |sum, val| sum + val.send(attribute) } / set.size
  end

  def _data_to_faketime_pairs(start, data)
    pairs = []

    data.each_with_index do |value, i|
      pairs << [start + i, value]
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
  @sensors,
    @past_day,
    @past_day_watt_hours,
    @past_week,
    @past_week_watt_hours = Cache.fetch(:expires_at => Time.now + 10) do
    past_day = {}
    past_week = {}

    sensors = Sensor.all
    sensors.each do |sensor|
      day_intervals = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60*24))
      past_day[sensor] = downsample(day_intervals, NUM_INTERVALS)

      week_intervals = Interval.all(:sensor => sensor, :created_at.gt => Time.now - (60*60*24 * 7))
      past_week[sensor] = downsample(week_intervals, NUM_INTERVALS)
    end

    past_day_watt_hours = watt_hours(past_day)
    past_week_watt_hours = watt_hours(past_week)

    [sensors, past_day, watt_hours(past_day), past_week, watt_hours(past_week)]
  end

  erb :graph
end
