ENV["RAILS_ENV"] ||= "test"

require "settings"
require "fileutils"

describe Settings do 
  before :each do 
    Settings.config_file File.expand_path("../config/settings.yml", __FILE__)
  end

  describe "node access" do 
    it "set a value" do 
      Settings.test = 1
      Settings.test.should == 1
    end

    it "get a value" do 

      Settings.settings["hi"] = "World"
      Settings.hi.should == "World"
    end

    it "set a high level value" do 
      Settings.this.a.data = "1"
      Settings.this.a.data.should == "1"
    end

    it "change a high level value" do 
      Settings.that.a.data
      Settings.that.a.data = 'hi'
      Settings.that.a.data.should == 'hi'
    end

    it "change multi high level value" do 
      Settings.that.a.data
      Settings.that.a.data = 'hi'
      Settings.that.a.data.should == 'hi'
      Settings.that.a.name = 'hysios'
      Settings.that.a.age = 18
      Settings.that.a.name.should == 'hysios'
      Settings.that.a.age.should == 18
    end    

    it "default value" do 
      Settings.this.a.default_value 1234
      Settings.this.a.default_value.should == 1234
    end

    it "always value invalide default value" do 
      Settings.this.always.default_value = 5678
      Settings.this.always.default_value 1111
      Settings.this.always.default_value.should == 5678
    end

  end

  describe "load and save" do 
    before :each do 
      FileUtils.mkdir_p File.expand_path("../../tmp", __FILE__)
      Settings.config_file File.expand_path("../config/data.yml", __FILE__)
    end

    let(:temp_file) {
      File.expand_path("../../tmp/temp.yml", __FILE__)
    }

    it "save" do 
      Settings.config_file temp_file
      Settings.ready = "asdfasdf"
      Settings.save

      hash = YAML.load_file(temp_file)[ENV["RAILS_ENV"]]
      hash.should include("ready" => "asdfasdf")
      # Settings.save
    end

    it "load" do 
      Settings.load
      Settings.loading.from.file.should == 1234
    end

    it "load and set" do 
      Settings.load
      Settings.loading.from.file.should == 1234
      Settings.loading.from.disk = 'A'
      Settings.loading.from.should include("file" => 1234, "disk" => "A")
    end    

    it "load and save" do 
      Settings.load
      Settings.loading.from.file.should == 1234
      Settings.loading.from.disk = 'A'
      Settings.config_file temp_file
      Settings.save

      hash = YAML.load_file(temp_file)[ENV["RAILS_ENV"]]
      hash.should include("loading")
      from = hash["loading"]["from"]
      from.should include("file" => 1234, "disk" => "A")

    end    
  end


  describe "monitor" do 
    let (:matches) { [] }

    def line_match(conditions, &block)
      cond = conditions[matches.size]
      ret = cond.call
      if ret
        matches.push ret
      else
        matches.clear
      end

      if matches.size == conditions.size
        block.call
      end
    end

    before :each do 
      FileUtils.mkdir_p File.expand_path("../../tmp", __FILE__)
      Settings.config_file File.expand_path("../config/data.yml", __FILE__)
      Settings.monitor.test = 1
      Settings.save
    end

    it "change file auto sync settings" do 
      File.open(File.expand_path("../config/data.yml", __FILE__)) do |f|
        line_match [
          ->() { f.readline.strip == 'monitor' },
          ->() { f.readline.strip == 'test: 1' }
        ] do  
          f.seek -1, IO::SEEK_CUR
          f.write 2
          f.close
          sleep 0.5
          Settings.monitor.test.should == 2
        end
      end
    end

  end
end