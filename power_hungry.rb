require 'rubygems'
require 'serialport'

require 'lib/power_hungry/history'
require 'lib/power_hungry/reading'
require 'lib/power_hungry/database'
require 'lib/xbee/packet'

class PowerHungry
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
    PowerHungry::Reading.new(packet, @debug)
  end

  def run
    puts "Power Hungry network up and running on #{DateTime.now.strftime("%Y-%m-%d %H:%M")}"
    while true
      reading = next_reading
      puts reading.to_s if @debug

      PowerHungry::History.add(reading.sensor, reading.watt_hours)
      if PowerHungry::History.interval_passed?
        PowerHungry::History.sensors.each do |sensor|
          puts "#{[sensor.name, sensor.id].compact.first}: Watt-hours used in the past #{PowerHungry::History::INTERVAL_LENGTH} seconds: #{PowerHungry::History.interval_watt_hours(sensor)}"
          Interval.create!(:watt_hours => PowerHungry::History.interval_watt_hours(sensor), :interval_length => PowerHungry::History::INTERVAL_LENGTH, :sensor => sensor)
        end
        PowerHungry::History.restart
      else
      end
    end
  end
end

PowerHungry::Database.connect
