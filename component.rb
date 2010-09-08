#!/usr/bin/env ruby

require 'optparse'

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/lib/derailed/daemon'

OptionParser.new do |opts|
  opts.on('-t', '--test', 'use test environment') do
    ENV['ENV'] = 'test'
  end
  opts.on('-d', '--development', 'use development environment') do
    ENV['ENV'] = 'development'
  end
  opts.on('-p', '--production', 'use production environment') do
    ENV['ENV'] = 'production'
  end
  opts.on('-m', '--manager', 'start/stop Manager') do
    manager = Derailed::Manager::Interface.new
    daemon = Derailed::Daemon.manager
    daemon.daemonize do
      manager.daemonize
    end
  end
  opts.on('-c', '--component COMPONENT',
          'start/stop the specified component') do |c|
    config = YAML::load(File.open(Derailed::Config::RootDir +
                                  "/components-enabled/#{c}/config.yml"))
    daemon = Derailed::Daemon.component(config['name'])
    config['class'] ||= 'Base'
    config['class'] = Derailed::Component.const_get(config['class'])
    config['requirements'] ||= []
    daemon.daemonize(config['class'],config['requirements'])
  end
end.parse!
