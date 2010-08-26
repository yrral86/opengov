#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/derailed'

class OpenGovStaticComponent < Derailed::Component::Base
  def routes
    ['javascript','images']
  end

  def call(env)
    super(env, false)
    begin
      case path(1)
      when 'javascript'
        View.render_string(File.read(Config::RootDir +
                                            controller.request.path))
      when 'images'
        View.render_string("TODO: return images")
      else
        View.not_found("File #{controller.request.path} not found")
      end
    rescue
      View.not_found("File #{controller.request.path} not found")
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
