class PowerHungry
  class History
    INTERVAL_LENGTH = 5 * 60

    def self.add(sensor, watthr, watts)
      @histories[sensor] = { :watts => [], :interval_watt_hours => 0 } unless @histories.has_key?(sensor)
      @histories[sensor][:interval_watt_hours] += watthr
      @histories[sensor][:watts] << watts
    end

    def self.elapsed_time
      Time.now - @interval_start_time
    end

    def self.interval_passed?
      elapsed_time >= INTERVAL_LENGTH
    end

    def self.interval_watt_hours(sensor)
      @histories[sensor][:interval_watt_hours] * (60.0 * 60 / (elapsed_time))
    end

    def self.interval_watts_avg(sensor)
      @histories[sensor][:watts].inject(0.0) {|sum, w| sum + w} / @histories[sensor][:watts].size
    end

    def self.restart
      @interval_start_time = Time.now

      @histories = { }
    end

    def self.sensors
      @histories.keys
    end
  end
end

PowerHungry::History.restart
