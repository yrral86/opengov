#!/usr/bin/env ruby

require 'yaml'
require 'optparse'

dir = File.expand_path(File.dirname(__FILE__))
libraries = "#{dir}/lib"
$:.unshift libraries

component = nil
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
    component = :manager
  end
  opts.on('-c', '--component COMPONENT',
          'start/stop the specified component') do |c|
    component = c
  end
end.parse!

require 'derailed/daemon'

if component == :manager
  Derailed::Daemon.manager.daemonize
elsif component
  config = YAML::load(File.open(Derailed::Config::ComponentDir +
                                "/#{component}/config.yml"))
  daemon = Derailed::Daemon.component(config['name'])
  config['class'] ||= 'Base'
  config['class'] = Derailed::Component.const_get(config['class'])
  config['requirements'] ||= []
  daemon.daemonize(config['class'],config['requirements'])
else
  puts "You must specify -m or -c, see #{$0} -h"
end
