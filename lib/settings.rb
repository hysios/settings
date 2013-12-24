require "yaml"

# config = YAML::load_file("#{Rails.root}/config/application.yml")[Rails.env]
# Settings.defaults = config

module Settings

  class SettingsNode < Hash


    def method_missing(meth, *args, &block)

      meth = meth.to_s
      eigenclass = class << self; self; end

      if meth[-1] == '=' # write
        eigenclass.class_eval do
          define_method(meth) do |value|
            self[meth.slice(0..-2)] = value
          end
        end
      else
        eigenclass.class_eval do
          define_method(meth) do |*args|
            value = args[0]
            if self.has_key?(meth)
              if self[meth].is_a?(Hash)
                SettingsNode[self[meth]]
              else
                self[meth]
              end
            else
              self[meth] = value || SettingsNode.new
            end
          end
        end
      end
      send(meth, *args, &block)     
    end

    def generate_method(meth, value)
      eigenclass.class_eval do
        define_method(meth) do |value|
          self[meth.slice(0..-2)] = value
        end
      end

      eigenclass.class_eval do
        define_method(meth) do |*args|
          value = args[0]
          if self.has_key?(meth)
            if self[meth].is_a?(Hash)
              SettingsNode[self[meth]]
            else
              self[meth]
            end
          else
            self[meth] = value || SettingsNode.new
          end
        end
      end

      send(meth, value, &block) 
    end

    def load_form_hash(hash)
      hash.each do |k, value|
        if value.is_a?(Hash)
          load_form_hash(value)
        else
          generate_method(k ,value)
        end
      end
    end
  end

  class << self
    SETTINGS_FILE = "#{Rails.root}/config/settings.yml"

    @@settings = SettingsNode.new

    def method_missing(meth, *args, &block)
      puts meth, *args
      meth = meth.to_s
      eigenclass = class << self; self; end

      if meth[-1] == '=' # write
        eigenclass.class_eval do
          define_method(meth) do |value|
            @@settings[meth.slice(0..-2)] = value
          end
        end
      else
        eigenclass.class_eval do
          define_method(meth) do |*args|
            value = args[0]
            if @@settings.has_key?(meth)
              if @@settings[meth].is_a?(Hash)
                SettingsNode[@@settings[meth]]
              else
                @@settings[meth]
              end
            else
              @@settings[meth] = value || SettingsNode.new
            end            
          end
        end
      end
      send(meth, *args, &block)     
    end

    def values
      @@settings
    end

    def load
      @all_settings = nil
      @@settings = all_settings[env]
    end

    def save
      all_settings[env] = @@settings
      File.open(SETTINGS_FILE, 'w+') {|f| f.write all_settings.to_yaml } 
    end   

    # protected

    def env 
      Rails.env.to_s      
    end

    def all_settings
      @all_settings ||= YAML::load_file(SETTINGS_FILE) 
    rescue Errno::ENOENT
      @all_settings = {}
    end
  end
end