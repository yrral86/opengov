require 'daemons'

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../derailed'


module Derailed
  class Daemon
    Component = 0
    Manager = 1

    def initialize(name, type=Component, db='default')
      @name = name
      @type = type

      if type == Component
        init_ar(db)
        require_models
      end
    end

    def init_ar(db)
      conf = YAML::load(File.open(Config::RootDir + '/db/config.yml'))[db]
      ActiveRecord::Base.establish_connection(conf[Config::Environment])
    end

    def require_models
      dir = Config::RootDir + "/components-enabled/#{@name.downcase}"
      original = class_list
      require_dir(dir)
      new = class_list
      new_modules = new - original
      @new_models = new_modules.select do |m|
        m.superclass == Derailed::Component::Model ||
        m.superclass == Authlogic::Session::Base
      end
    end

    def class_list
      array = []
      ObjectSpace.each_object(Class) {|m| array << m }
      array
    end

    def require_dir(dir)
      old_dir = Dir.pwd
      Dir.chdir dir
      Dir.glob '**/*.rb' do |f|
        require f unless f == 'init.rb'
      end
      Dir.chdir old_dir
    end

    def self.component(name)
      new(name)
    end

    def self.manager
      new('OpenGovManager', Manager)
    end

    def daemonize(klass=Derailed::Component::Base,requirements=[])
      name = @type == Component ? "OpenGov#{@name}Component" : @name
      Daemons.run_proc(name, {:dir_mode => :normal, :dir => Config::RootDir}) do
        if block_given?
          yield
        else # assumes component as manager has a block
          klass.new(@name, @new_models, [], requirements).daemonize
        end
      end
    end
  end
end
