#!/usr/bin/env ruby

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
  require 'daemons'
  require 'derailed/manager/interface'
  Daemons.run_proc('OpenGovManager', {:dir_mode => :normal,
                         :dir => Derailed::Config::RootDir}) do
    Derailed::Manager::Interface.new.daemonize
  end
elsif component
  require 'derailed/componentclient'
  command = ARGV.first
  begin
    manager = Derailed::ComponentClient.new.manager
    unless command == 'run'
      puts manager.component_command(component, command)
    else
      require 'derailed'
      manager.component_pid(component, Process.pid)
      Derailed::Component::Daemon.new(component).run
    end
  rescue DRb::DRbConnError
    puts 'Manager is not running'
  end
else
  puts "You must specify -m or -c, see #{$0} -h"
end
