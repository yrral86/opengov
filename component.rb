#!/usr/bin/env ruby

require 'optparse'

dir = File.expand_path(File.dirname(__FILE__))
require dir + '/lib/derailed/daemon'

OptionParser.new do |opts|
  opts.on('-c', '--component COMPONENT',
          'start/stop the specified component') do |c|
    config = YAML::load(File.open(Derailed::Config::RootDir +
                                  "/components-enabled/#{c}/config.yml"))
    component = Derailed::Daemon.component(config['name'])
    config['class'] ||= 'Base'
    config['class'] = Derailed::Component.const_get(config['class'])
    config['requirements'] ||= []
    component.daemonize(config['class'],config['requirements'])
  end
end.parse!
