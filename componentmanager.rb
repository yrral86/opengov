#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require 'drb'
require 'drb/unix'
require 'rubygems'
require 'daemons'
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

require dir + '/lib/derailed'

cm = Derailed::Manager::Interface.new

Daemons.run_proc('OpenGovManager',
                 {:dir_mode => :normal, :dir => dir}) do
  cm.daemonize
end

