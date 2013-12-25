require "yaml"

# config = YAML::load_file("#{Rails.root}/config/application.yml")[Rails.env]
# Settings.defaults = config

module Settings

  module GenerateAccessorMethods

    def GenerateAccessorMethods.included(klass)
      klass.extend(ClassMethods)
      klass.class_variable_set(:@@target, nil)
    end

    def generate_accessor_methods(method)
      generate_writer_method(method)
      generate_reader_method(method)
    end

    def generate_writer_method(method)
      eigenclass = class << self; self; end
      meth = method + '='
      eigenclass.class_eval do
        define_method(meth) do |value|
          write_property(method, value)
        end
      end
    end

    def generate_reader_method(method)
      eigenclass = class << self; self; end
      eigenclass.class_eval do
        define_method(method) do |*args|
          value = args.first
          if value.nil?
            read_property(method)
          else
            write_property(method, value)
          end
        end
      end
    end

    def write_property(name, value)
      target[name] = value
    end

    def read_property(name)

      if target[name].nil?
        target[name] = Node.new
      elsif target[name].is_a?(Hash)
        target[name] = build_hash(target[name])
      else
        target[name]
      end
    end

    def target
      self
    end

    def build_hash(hash)
      hash.each do |k, v|
        if v.is_a?(Hash)
          hash[k] = build_hash(v)
        end
      end
      Node[hash]
    end

    module ClassMethods

      def set_store(store)
        # @@target = store

        class_eval %(

          def target
            send('#{store}')
          end
        )        
      end
    end
  end

  class Node < Hash
    IGNORE_METHOS = [ :method_missing, :class_variables_get=, :class_variables_get, :generate_accessor_methods, :generate_writer_method, :generate_reader_method, :target, :freeze, :===, :==, :<=>, :<, :<=, :>, :>=, :to_s, :inspect, :included_modules, :include?, :ancestors, :instance_methods, :public_instance_methods, :protected_instance_methods, :private_instance_methods, :constants, :const_get, :const_set, :const_defined?, :const_missing, :class_variables, :remove_class_variable, :class_variable_get, :class_variable_set, :class_variable_defined?, :public_constant, :private_constant, :module_exec, :class_exec, :module_eval, :class_eval, :method_defined?, :public_method_defined?, :private_method_defined?, :protected_method_defined?, :public_class_method, :private_class_method, :autoload, :autoload?, :instance_method, :public_instance_method, :psych_yaml_as, :yaml_as, :psych_to_yaml, :to_yaml, :to_yaml_properties, :nil?, :=~, :!~, :eql?, :hash, :class, :singleton_class, :clone, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :frozen?, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :define_singleton_method, :object_id, :to_enum, :to_ary, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]

    include GenerateAccessorMethods

    def method_missing(meth, *args, &block)
      if !IGNORE_METHOS.include?(meth)
        method = meth.to_s.chomp('=')
        generate_accessor_methods(method)
        send(meth, *args, &block)
      else
        super
      end
    end

    def class
      Hash
    end
  end

  class << self
    IGNORE_METHOS = [:settings, :settings=, :config_file, :method_missing, :load, :save, :env, :all_settings, :class_variables_get=, :class_variables_get, :generate_accessor_methods, :generate_writer_method, :generate_reader_method, :target, :freeze, :===, :==, :<=>, :<, :<=, :>, :>=, :to_s, :inspect, :included_modules, :include?, :name, :ancestors, :instance_methods, :public_instance_methods, :protected_instance_methods, :private_instance_methods, :constants, :const_get, :const_set, :const_defined?, :const_missing, :class_variables, :remove_class_variable, :class_variable_get, :class_variable_set, :class_variable_defined?, :public_constant, :private_constant, :module_exec, :class_exec, :module_eval, :class_eval, :method_defined?, :public_method_defined?, :private_method_defined?, :protected_method_defined?, :public_class_method, :private_class_method, :autoload, :autoload?, :instance_method, :public_instance_method, :psych_yaml_as, :yaml_as, :psych_to_yaml, :to_yaml, :to_yaml_properties, :nil?, :=~, :!~, :eql?, :hash, :class, :singleton_class, :clone, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :frozen?, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :define_singleton_method, :object_id, :to_enum, :to_ary, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]

    include GenerateAccessorMethods

    attr_accessor :settings

    set_store :settings

    if defined?(Rails)
      @@config_file  = "#{Rails.root}/config/settings.yml"
    end

    def config_file(file)
      @@config_file = file 
    end

    def settings
      @settings ||= Node.new
    end

    def method_missing(meth, *args, &block)
      if !IGNORE_METHOS.include?(meth)
        method =  meth.to_s.chomp('=')
        generate_accessor_methods(method)
        send(meth, *args, &block)     
      else
        super
      end
    end

    def load
      @all_settings = nil
      @settings = all_settings[env]
    end

    def save
      all_settings[env] = @settings
      File.open( @@config_file, 'w+' ) {|f| f.write all_settings.to_yaml } 
    end   

    protected

    def env
      ENV["RAILS_ENV"] || "development"
    end

    def all_settings
      @all_settings ||= YAML::load_file( @@config_file ) 
    rescue Errno::ENOENT
      @all_settings = {}
    end
  end
end