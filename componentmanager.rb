#!/usr/bin/env ruby

dir = File.expand_path(File.dirname(__FILE__))

require 'drb'
require 'drb/unix'
require 'rubygems'
require 'optparse'

optparse = OptionParser.new do |opts|
  opts.on('--test') do
    ENV['ENV'] = 'test'
  end
  opts.on('--development') do
    ENV['ENV'] = 'development'
  end
  opts.on('--production') do
    ENV['ENV'] = 'production'
  end
end
optparse.parse!

require dir + '/lib/derailed/daemon'

manager = Derailed::Manager::Interface.new

Derailed::Daemon.manager.daemonize do
  manager.daemonize
end

