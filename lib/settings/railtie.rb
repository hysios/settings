module Settings
  class Railtie < Rails::Railtie
    initializer "settings.rails_load_initialization" do |app|
      if defined?(Rails) && Rails.root
        Settings.config_file Rails.root.join("config/settings.yml")
        Settings.load
      end
    end
  end
end