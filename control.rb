#!/usr/bin/env ruby

require 'yaml'
require 'optparse'

dir = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{dir}/lib"

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
  require 'derailed/manager/components'
  config = Derailed::Manager::Components.read_component_config(component)
  Derailed::Daemon.component(config).daemonize
else
  puts "You must specify -m or -c, see #{$0} -h"
end
