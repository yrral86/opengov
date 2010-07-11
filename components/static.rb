#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
require dir + '/../lib/view'

class OpenGovStaticComponent < OpenGovComponent
  def routes
    ['javascript','images']
  end

  def call(env)
    begin
      case env[:parser].path(1)
      when 'javascript'
        OpenGovView.render_string(File.read(Config::RootDir +
                                            env[:parser].request.path))
      when 'images'
        OpenGovView.render_string("TODO: return images")
      else
        OpenGovView.not_found("File #{env[:parser].request.path} not found")
      end
    rescue
      OpenGovView.not_found("File #{env[:parser].request.path} not found")
    end
  end
end

Daemons.run_proc('OpenGovStaticComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovStaticComponent.new(
                             'Static',
                             [],
                             []
                             ).daemonize
end
