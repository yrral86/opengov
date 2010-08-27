module Derailed
  module Controller
#--
    # = Derailed::Controller::Controller
    # This module provides a controller object that is used both in the
    # components (functions provided by Derailed::Component::Controller),
    # and also by Authlogic (set in
    # Derailed::Component::Authentication.setup_env)
    class Controller
      # session is a hash that is saved and restored via the session
      # provided by Rack::Session::Cookie. This is included via the Rack
      # config file (config.ru).  session is extended with DRbUndumped, so
      # it will stay in the RequestRouter process
      attr :session, true
      # cookies is a hash that is saved and restored via the cookie support
      # built into rack.  cookies is extended with DRbUndumped, so it will stay
      # in the RequestRouter process
      attr :cookies, true

      # initialize handles setting up the controller, including extracting the
      # path, and restoring the session and cookies from the request
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

      # init_cookies initialized the cookies hash by copying all key value pairs
      # from the request
      def init_cookies
        c = {}
        c.extend(DRbUndumped)
        c.extend(CookieFix)
        @r.cookies.keys.each do |k|
          c[k] = @r.cookies[k]['value']
        end
        c
      end

      # next returns the next piece of the path
      # ===== example: /extra/long/test/path/
      # 1st call:: 'extra'
      # 2nd call:: 'long'
      # 3rd call:: 'test'
      # 4th call:: 'path'
      def next
        @queue.shift
      end

      # path(n) gets the nth string of the path, split by /
      # ===== example: /extra/long/test/path/
      # path(0):: ''
      # path(1):: 'extra'
      # path(2):: 'long'
      # path(3):: 'test'
      # path(4):: 'path'
      def path(n)
        @paths[n]
      end

      # request returns the request object created in initialize via
      # Rack::Request.new(env)
      def request
        @r
      end

      # save_session saves the session and cookie hashes back into the response
      def save_session(response)
        @env['rack.session'] = @session.dup
        @cookies.keys.each do |k|
          response.set_cookie k, @cookies[k]
        end
      end

      # params returns the request params
      def params
        @r.params
      end

      # I'm not sure where I ripped this from, but it seems to work.
      # Simply returning false might work too (required by Authlogic)
      def authenticate_with_http_basic(&block)
        @auth = Rack::Auth::Basic::Request.new(@env)
        if @auth.provided? and @auth.basic?
          block.call(*@auth.credentials)
        else
          false
        end
      end

      # cookie_domain returns the HTTP_HOST header, which will be used to
      # set the domain for cookies (required by Authlogic)
      def cookie_domain
        @env['HTTP_HOST']
      end
    end
#++
  end
end
