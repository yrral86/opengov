require 'rack'

class OpenGovRequestParser
  def initialize(env)
    @env = env
    @r = Rack::Request.new(env)
    @paths = @r.path.split '/'
    @queue = Array.new @paths
    @queue.shift
  end

  def next
    @queue.shift
  end

  def path(n)
    @paths[n]
  end

  def request
    @r
  end

  def session
    @env['rack.session']
  end

  def params
    @r.params
  end

  def cookies
    @r.cookies
  end  
end
