require 'listen'

module Settings

  module Monitor

    class << self

      def listener
        file = Settings.class_variable_get(:@@config_file)
        base_path = File.dirname(file)
        @listener ||= Listen.to(base_path)  do |modified, added, removed|
          if modified.include?(file)
            Settings.load
          end
        end
      end

      def disable
        listener.pause
      end 

      def enable
        listener.unpause
      end
    end
  end
end