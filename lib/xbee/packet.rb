class XBee
  class Packet
    START_IOPACKET   = 0x7e
    SERIES1_IOPACKET = 0x83

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
        puts "XBee packet received:"
      end

      _parse_data(@packet_data)

      if @debug
        puts "address: #{address}"
        puts "address broadcast: #{address_broadcast}"
        puts "pan broadcast: #{pan_broadcast}"
        puts
        # puts "digital samples: #{@digital_samples.inspect}"
        # puts "analog samples: #{@analog_samples.inspect}"
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

    def _load_analog_sample(sample_number)
      analog_count = nil
      dataADC = Array.new(6, nil)
      analog_channels = @channel_indicator_high >> 1
      validanalog = 0
      dataADC.each_with_index do |d, i|
        if ((analog_channels >> i) & 1) == 1
          validanalog += 1
        end
      end

      dataADC.each_with_index do |d, i|
        if (analog_channels & 1) == 1:
          analogchan = 0
          i.times do |j|
            if ((@channel_indicator_high >> (j+1)) & 1) == 1:
              analogchan += 1
            end
          end

          dataADCMSB = @packet_data[8 + validanalog * sample_number * 2 + analogchan* 2]
          dataADCLSB = @packet_data[8 + validanalog * sample_number * 2 + analogchan* 2 + 1]
          dataADC[i] = ((dataADCMSB << 8) + dataADCLSB)# / 64

          analog_count = i
        end
        analog_channels = analog_channels >> 1
      end

      dataADC
    end

    def _load_digital_sample
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
        puts "#{field}: #{data[i]} (0x#{data[i].to_i.to_s(16)})" if @debug
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
