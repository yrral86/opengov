require 'rack'
require 'drb'

class OpenGovController
  def initialize(app)
    @app = app
  end

  def call(env)
    load_parser(env)
    status, headers, body = @app.call(env)
    commit_parser(env, status, headers, body)
  end

  private

  def load_parser(env)
    env[:controller] = OpenGovRequestController.new(env)
  end

  def commit_parser(env, status, headers, body)
    env[:controller].save_session
    [status, headers, body]
  end
end

class OpenGovRequestController
  attr :session, true

  def initialize(env)
    @env = env
    @r = Rack::Request.new(env)
    @paths = @r.path.split '/'
    @queue = Array.new @paths
    @queue.shift
    @env['rack.session'] ||= {}
    @session = @env['rack.session']
    @session.extend(DRbUndumped)
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

  def save_session
    @env['rack.session'] = @session.dup
  end

  def params
    @r.params
  end

  def cookies
    @r.cookies
  end

  def authenticate_with_http_basic(&block)
    @auth = Rack::Auth::Basic::Request.new(@env)
    if @auth.provided? and @auth.basic?
      block.call(*@auth.credentials)
    else
      false
    end
  end

  def cookie_domain
    @env['HTTP_HOST']
  end
end
