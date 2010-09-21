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

if component == :manager
  require 'derailed/daemon'
  Derailed::Daemon.manager.daemonize
elsif component
  require 'derailed/componentclient'
  command = ARGV.first
  unless command == 'run'
    Derailed::ComponentClient.new.cm.component_command(component, command)
  else
    require 'derailed/daemon'
    Derailed::ComponentClient.new.cm.component_pid(component, Process.pid)
    Derailed::Daemon.component(component).component_proc.call
  end
else
  puts "You must specify -m or -c, see #{$0} -h"
end
