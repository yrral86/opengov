require 'lib/componenthelper'
require 'lib/authenticatorhelper'
require 'lib/view'

class OpenGovRequestRouter
  def initialize
    @ch = OpenGovComponentHelper.new
    @routes = {}
    @view = OpenGovView
    DRb.start_service
    self
  end

  def call(env)
    @routes = @ch.get_routes if @routes.empty?

    component = env[:controller].next
    if @routes[component] == nil then
      @view.not_found 'Not Found'
    else
      begin
        @routes[component].call(env)
      rescue DRb::DRbConnError
        @routes = {}
        @view.not_found "Component #{component} went away"
      end
    end
  end
end
