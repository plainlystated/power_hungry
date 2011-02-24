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
    while true
      puts next_reading.to_s
    end
  end

  def next_reading
    packet = XBee::Packet.new(@serial)
    WattcherNetwork::Reading.new(packet)
  end
end

WattcherNetwork::Database.connect

if ARGV[0] == 'debug'
  serial = SerialPort.new(WattcherNetwork::SERIALPORT)
  wattcher = WattcherNetwork.new
  wattcher.debug
end

