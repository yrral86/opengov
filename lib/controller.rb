require 'rack'
require 'drb'

require 'lib/componenthelper'
require 'lib/view'

class OpenGovController
  def initialize(app)
    @app = app
    @ch = OpenGovComponentHelper.new
  end

  def call(env)
    load_parser(env)
    status, headers, body = authenticate(env) do |env|
      @app.call(env)
    end
    commit_parser(env, status, headers, body)
  end

  private

  def authenticate(env)
    if @ch.get_current_session(env) or env[:controller].request.path == '/login'
      yield env
    else
      env[:controller].session[:onlogin] = env[:controller].request.path
      OpenGovView.redirect('/login')
    end
  end

  def load_parser(env)
    env[:controller] = OpenGovRequestController.new(env)
  end

  def commit_parser(env, status, headers, body)
    response = Rack::Response.new(body, status, headers)
    env[:controller].save_session(response)
    [status, headers, body]
  end
end

class OpenGovRequestController
  attr :session, true
  attr :cookies, true

  def initialize(env)
    @env = env
    @r = Rack::Request.new(env)
    @paths = @r.path.split '/'
    @queue = Array.new @paths
    @queue.shift
    @env['rack.session'] ||= {}
    @session = @env['rack.session']
    @session.extend(DRbUndumped)
    @cookies = init_cookies
  end

  def init_cookies
    c = {}
    c.extend(DRbUndumped)
    c.extend(CookieFix)
    @r.cookies.keys.each do |k|
      c[k] = @r.cookies[k]['value']
    end
    c
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

  def save_session(response)
    @env['rack.session'] = @session.dup
    @cookies.keys.each do |k|
      response.set_cookie k, @cookies[k]
    end
  end

  def params
    @r.params
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

module CookieFix
  def delete(key, options = {})
    super(key)
  end
end
