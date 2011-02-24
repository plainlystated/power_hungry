require 'rubygems'
require 'sinatra'
require 'lib/wattcher_network/database'

WattcherNetwork::Database.connect

helpers do
  def amps
    _data_to_microsecond_pairs(@reading.amperage_data, @reading.updated_at)
  end

  def amps_bounds
    if @reading.amperage_data.min.abs > @reading.amperage_data.max
      @reading.amperage_data.min.abs
    else
      @reading.amperage_data.max
    end
  end

  def interval_points(intervals)
    intervals.map do |interval|
      [_to_timestamp(interval.updated_at), interval.watt_hours]
    end
  end

  def voltages
    _data_to_microsecond_pairs(@reading.voltage_data, @reading.updated_at)
  end

  def watts
    _data_to_microsecond_pairs(@reading.wattage_data, @reading.updated_at)
  end

  def _data_to_microsecond_pairs(data, start)
    puts start
    time = Time.parse(start.to_s)
    time = time.to_i * 1000
    time = time - 2000
    data.map do |datum|
      time += 1
      [time, datum]
    end
  end

  def _to_timestamp(datetime)
    Time.parse(datetime.to_s).to_i * 1000
  end
end

get '/' do
  @reading = CurrentReading.first
  @past_hour = Interval.all(:created_at.gt => DateTime.now - (60*60))

  erb :graph
end


