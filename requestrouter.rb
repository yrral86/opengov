require 'lib/componenthelper'
require 'lib/requestparser.rb'

class OpenGovRequestRouter
  def initialize
    @ch = OpenGovComponentHelper.new
    @routes = {}
    DRb.start_service
    self
  end

  def call(env)
    @routes = @ch.get_routes if @routes.empty?

    env[:parser] = OpenGovRequestParser.new(env)

    component = env[:parser].next

    if @routes[component] == nil then
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    else
      begin
        @routes[component].call(env)
      rescue DRb::DRbConnError
        @routes = {}
        [404, {'Content-Type' => 'text/html'}, ["Component #{component} went away"]]
      end
    end
  end
end
