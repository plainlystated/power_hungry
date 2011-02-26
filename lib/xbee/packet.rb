class XBee
  class Packet
    START_IOPACKET   = 0x7e
    SERIES1_IOPACKET = 0x83

    ANALOG_SAMPLE_WIDTH = 2

    FIELDS = [
      :app_id,
      :address_msb,
      :address_lsb,
      :rssi,
      :broadcast_data,
      :total_samples,
      :channel_indicator_high,
      :channel_indicator_low,
      :digital_msb,
      :digital_lsb
    ]

    FIELDS.each { |field| attr_reader field }
    attr_reader :analog_samples, :digital_samples

    def initialize(serial, debug = false)
      @debug = debug
      digital_samples = []
      analog_samples = []
      @packet_data = _read_packet(serial)
      if @debug
        puts
        puts "XBee packet received @ #{DateTime.now}:"
      end

      _parse_data(@packet_data)

      if @debug
        puts "address: #{address}"
        puts "address broadcast: #{address_broadcast}"
        puts "pan broadcast: #{pan_broadcast}"
        puts
        # puts "digital samples: #{@digital_samples.inspect}"
        puts "analog samples: #{@analog_samples.inspect}"
      end
    end

    def address
      (@address_msb << 8) + @address_lsb
    end

    def address_broadcast
      ((@broadcast_data >> 1) & 0x01) == 1
    end

    def pan_broadcast
      ((@broadcast_data >> 2) & 0x01) == 1
    end

    def _analog_channel_positions
      (@channel_indicator_high >> 1).to_s(2).split("").map {|p| p == "1" }
    end

    def _analog_reading_at_position?(position)
      _analog_channel_positions[position]
    end

    def _analog_channel_count
      _analog_channel_positions.select {|b| b }.size
    end

    def _enabled_analog_channels
      channels = []
      _analog_channel_positions.each_with_index do |enabled, i|
        channels << i if enabled
      end
      channels
    end

    def _load_analog_sample(sample_number)
      puts "\nReading sample #{sample_number}" if @debug

      sample = Array.new(6, nil)
      puts "enabled analog channels: #{_enabled_analog_channels.inspect}" if @debug

      sample.each_with_index do |d, position|
        if _analog_reading_at_position?(position)
          puts "[#{position}] checking sample for value on channel #{position}" if @debug

          # Assume no digital data (in this project), so ADC data starts at byte 8
          analog_data_start_position = 8

          channel_offset_within_sample = _enabled_analog_channels.index(position) * ANALOG_SAMPLE_WIDTH
          puts "[#{position}] analog channel offset (bytes) within sample: #{channel_offset_within_sample}" if @debug

          sample_offset = _enabled_analog_channels.size * sample_number * ANALOG_SAMPLE_WIDTH

          dataADCMSB = @packet_data[analog_data_start_position + sample_offset + channel_offset_within_sample]
          dataADCLSB = @packet_data[analog_data_start_position + sample_offset + channel_offset_within_sample + 1]
          sample[position] = ((dataADCMSB << 8) + dataADCLSB)

          puts "[#{position}] #{[dataADCMSB, dataADCLSB].map {|b| "%08b" % b}.join("")} (#{sample[position]})" if @debug
        end
      end

      p sample if @debug
      sample
    end

    def _load_digital_sample
      # We don't actually have any digital data in this project..  leaving this example code for future projects

      dataD = Array.new(9, nil)
      digital_channels = @channel_indicator_low
      digital = 0

      dataD.each_with_index do |d, i|
        if (digital_channels & 1) == 1
          dataD[i] = 0
          digital = 1
        end

        digital_channels = digital_channels >> 1
      end

      if (@channel_indicator_high & 1) == 1
        dataD[8] = 0
        digital = 1
      end

      if digital
        dig = (@digital_msb << 8) + @digital_lsb
        dataD.each_with_index do |d, i|
          if dataD[i] == 0:
            dataD[i] = dig & 1
          end
          dig = dig >> 1
        end
      end

      dataD
    end

    def _parse_data(data)
      FIELDS.each_with_index do |field, i|
        instance_variable_set("@#{field}", data[i])
        puts "#{"%08b" % data[i]} #{field}: #{data[i]} (0x#{data[i].to_i.to_s(16)})" if @debug
      end
      (FIELDS.size - 1).upto(data.size) do |i|
        puts "#{"%08b" % data[i]}" if @debug
      end

      _parse_digital_samples
      _parse_analog_samples
    end

    def _parse_analog_samples
      @analog_samples ||= Array.new(@total_samples) do |sample_number|
        _load_analog_sample(sample_number)
      end
    end

    def _parse_digital_samples
      @digital_samples ||= Array.new(@total_samples) do |sample_number|
        _load_digital_sample
      end
    end

    def _read_packet(serial)
      start = Time.now
      i = 1
      until Time.now - start > 6
        if serial.getc == START_IOPACKET
          lengthMSB = serial.getc
          lengthLSB = serial.getc
          length = (lengthLSB + (lengthMSB << 8)) + 1

          return Array.new(length) { serial.getc }
        end
      end
    end
  end
end
