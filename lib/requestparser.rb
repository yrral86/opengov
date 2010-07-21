require 'rack'
#require 'action_controller/http_authentication'

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

  def authenticate_with_http_basic(&login_procedure)
    puts "authenticate_with_http_basic"
    true
  end

  def cookie_domain
    @env['HTTP_HOST']
  end
end
