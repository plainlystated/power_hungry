require 'rubygems'
require 'sinatra'
require 'wattcher'

serial = SerialPort.new("/dev/tty.usbserial-FTF66X1C")
wattcher = Wattcher.new

get '/hi' do
  "Hello world!"
end

get '/' do
  reading = wattcher.next_reading
  puts "read"

  @voltages, @amps, @watts = reading.voltage_data, reading.amperage_data, reading.wattage_data
  p @voltages
  @voltages = (1..@voltages.size).to_a.zip(@voltages)
  @amps = (1..@amps.size).to_a.zip(@amps)
  @watts = (1..@watts.size).to_a.zip(@watts)
  erb :graph
end


