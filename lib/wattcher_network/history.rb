class WattcherNetwork
  class History
    INTERVAL_LENGTH = 10

    @interval_watt_hours = 0
    @interval_start_time = Time.now

    def self.add(watthr)
      @interval_watt_hours += watthr
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
      @interval_start_time = Time.now
    end
  end
end
