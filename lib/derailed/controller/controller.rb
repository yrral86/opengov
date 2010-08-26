module Derailed
  module Controller
    class Controller
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
  end
end
