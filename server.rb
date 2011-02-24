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

get '/hi' do
  "Hello world!"
end

get '/' do
  reading = CurrentReading.first

  @voltages, @amps, @watts = reading.voltage_data, reading.amperage_data, reading.wattage_data
  erb :graph
end


