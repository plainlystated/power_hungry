class PowerHungry
  class Config
    CONFIG_FILE = File.join(File.dirname(__FILE__), '..', '..', 'config', 'power_hungry.yml')

    def self.init
      return if @inited

      @inited = true
      class << self
        YAML.load_file(CONFIG_FILE).each do |k,v|
          define_method(k) do
            v
          end
        end
      end
    end
  end
end
