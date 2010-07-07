#!/usr/bin/env ruby1.9.1

dir = File.dirname(__FILE__)

require dir + '/../lib/component'
require dir + '/../lib/view'

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
        OpenGovView.render_string(File.read(Config::RootDir + r.path))
      when 'images'
        OpenGovView.render_string("TODO: return images")
      else
        OpenGovView.not_found("File " + r.path + " not found")
      end
    rescue
      OpenGovView.not_found("File " + r.path + " not found")
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
