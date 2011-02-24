require 'rubygems'
require 'serialport'

require 'lib/wattcher_network/reading'
require 'lib/wattcher_network/database'
require 'lib/xbee/packet'

class WattcherNetwork
  SERIALPORT = "/dev/tty.usbserial-FTF66X1C"
  BAUDRATE = 9600

  def initialize
    @serial = SerialPort.new(SERIALPORT)
  end

  def debug
    @debug = true
    run
  end

  def next_reading
    packet = XBee::Packet.new(@serial, @debug)
    WattcherNetwork::Reading.new(packet, @debug)
  end

  def run
    puts "Wattcher Network up and running on #{DateTime.now.strftime("%Y-%m-%d %H:%M")}"
    while true
      reading = next_reading
      puts reading.to_s if @debug
    end
  end
end

WattcherNetwork::Database.connect
