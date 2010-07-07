#!/usr/bin/env ruby1.9.1

require 'daemons'

args = ARGV.join " "

`./componentmanager.rb #{args}`
`components/static.rb #{args}`
`components/personlocator.rb #{args}`
