class WattcherNetwork
  class History
    INTERVAL_LENGTH = 5 * 60

    def self.add(watthr, watts)
      @interval_watt_hours += watthr
      @interval_watts += watts
      @interval_readings += 1
    end

    def self.average_watts
      1.0 * @interval_watts / @interval_readings
    end

    def self.elapsed_time
      Time.now - @interval_start_time
    end

    def self.interval_passed?
      elapsed_time >= INTERVAL_LENGTH
    end

    def self.interval_watt_hours
      @interval_watt_hours * (60.0 * 60 / (elapsed_time))
    end

    def self.restart
      @interval_watt_hours = 0
      @interval_watts = 0
      @interval_readings = 0
      @interval_start_time = Time.now
    end
  end
end

WattcherNetwork::History.restart
