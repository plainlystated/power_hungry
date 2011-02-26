require 'rubygems'

require 'lib/power_hungry/config'
require 'lib/power_hungry/history'
require 'lib/power_hungry/reading'
require 'lib/power_hungry/database'
require 'lib/xbee/packet'

class PowerHungry
  def initialize
    @serial = IO.popen("python serial_proxy.py #{Config.serial_port}")
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
          puts "#{sensor.to_s}: Watt-hours used in the past #{PowerHungry::History::INTERVAL_LENGTH} seconds: #{PowerHungry::History.interval_watt_hours(sensor)}"
          Interval.create!(:watt_hours => PowerHungry::History.interval_watt_hours(sensor), :interval_length => PowerHungry::History::INTERVAL_LENGTH, :sensor => sensor)
        end
        PowerHungry::History.restart
      else
      end
    end
  end
end

PowerHungry::Config.init
PowerHungry::Database.connect
