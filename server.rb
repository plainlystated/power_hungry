require 'rubygems'
require 'sinatra'
require 'lib/wattcher_network/database'

WattcherNetwork::Database.connect

helpers do
  def amps
    _data_to_timeless_pairs(@amps)
  end

  def amps_bounds
    if @amps.min.abs > @amps.max
      @amps.min.abs
    else
      @amps.max
    end
  end

  def interval_points(intervals)
    intervals.map do |interval|
      time = Time.parse(interval.created_at.to_s)
      [time.to_i, interval.watt_hours]
    end
  end

  def voltages
    _data_to_timeless_pairs(@voltages)
  end

  def watts
    _data_to_timeless_pairs(@watts)
  end

  def _data_to_timeless_pairs(data)
    (1..data.size).to_a.zip(data)
  end
end

get '/' do
  reading = CurrentReading.first
  @past_hour = Interval.all(:created_at.gt => DateTime.now - (60*60))

  @voltages, @amps, @watts = reading.voltage_data, reading.amperage_data, reading.wattage_data
  erb :graph
end


