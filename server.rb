require 'rubygems'
require 'sinatra'
require 'lib/wattcher_network/database'

WattcherNetwork::Database.connect

helpers do
  def amps
    _data_to_timeless_pairs(@reading.amperage_data)
  end

  def amps_bounds
    bound = 0
    if @reading.amperage_data.min.abs > @reading.amperage_data.max
      bound = @reading.amperage_data.min.abs
    else
      bound = @reading.amperage_data.max
    end
    bound + (bound * 0.1)
  end

  def interval_points(intervals, method)
    intervals.map do |interval|
      [_to_timestamp(interval.updated_at), interval.send(method)]
    end
  end

  def voltages
    _data_to_timeless_pairs(@reading.voltage_data)
  end

  def watts
    _data_to_timeless_pairs(@reading.wattage_data)
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
  @reading = CurrentReading.first
  @past_hour = Interval.all(:created_at.gt => Time.now - (60*60))
  @past_day = Interval.all(:created_at.gt => Time.now - (60*60*24))

  erb :graph
end


