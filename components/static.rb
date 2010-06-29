#!/usr/bin/env ruby1.8

require 'lib/component'

class OpenGovStaticComponent < OpenGovComponent
  def routes
    ['javascript','images']
  end

  def call(env)
    r = Rack::Request.new(env)
    path = r.path.split "/"

    begin
      case path[1]
      when 'javascript'
        string_view(File.read(Config::RootDir + r.path))
      when 'images'
        string_view("TODO: return images")
      else
        not_found("File " + r.path + " not found")
      end
    rescue
      not_found("File " + r.path + " not found")
    end
  end
end

Daemons.run_proc('OpenGovStaticComponent') do
  OpenGovStaticComponent.new(
                             'Static',
                             [],
                             []
                             ).daemonize
end
