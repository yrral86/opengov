#!/usr/bin/env ruby1.9.1

require 'daemons'

path = File.dirname(__FILE__)
args = ARGV.join " "

`#{path}/componentmanager.rb #{args}`
`#{path}/components/static.rb #{args}`
`#{path}/components/personlocator.rb #{args}`
