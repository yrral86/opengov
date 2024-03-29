#!/usr/bin/env ruby

require 'optparse'

dir = File.expand_path(File.dirname(__FILE__))
$:.unshift "#{dir}/lib"

raw_component = false
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
    component = c.downcase
  end
  opts.on('-r', '--raw') do
    raw_component = true
  end
end.parse!

if component == :manager
  require 'daemons'
  require 'derailed/manager/interface'
  Daemons.run_proc('OpenGovManager', {:dir_mode => :normal,
                         :dir => Derailed::Config.pid_dir}) do
    Derailed::Manager::Interface.new.daemonize
  end
elsif component
  if raw_component
      require 'derailed'
    component = Derailed::Component::Daemon.new(component)
    component.run
  else
    require 'derailed/service'
    command = ARGV.first
    begin
      manager = Derailed::Service.get 'Manager'
      unless command == 'run'
        puts manager.component_command(component, command)
      else
        puts manager.component_command(component,'start')
        name = manager.component_command(component, 'name')
        require 'derailed/logger'
        IO.popen ("tail -f #{Derailed::Logger.log_file(name)}") do |f|
          while line = f.gets
            puts line
          end
        end
      end
    rescue DRb::DRbConnError
      puts 'Manager is not running'
    end
  end
else
  puts "You must specify -m or -c, see #{$0} -h"
end
