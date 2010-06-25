#!/usr/bin/env ruby1.8

require 'rubygems'
require 'daemons'

Daemons.run('components/personcomponent.rb')
