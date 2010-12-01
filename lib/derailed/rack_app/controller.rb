module Derailed
  module RackApp
    # = Derailed::RackApp::Controller
    # This module provides a controller object that is used both in the
    # components (functions provided by Derailed::Component::Environment),
    # and also by Authlogic (set in
    # Derailed::Component::Authenticator.setup_env)
    class Controller
      # session is a hash that is saved and restored via the session
      # provided by Rack::Session::Cookie. This is included via the Rack
      # config file (config.ru).  session is extended with DRbUndumped, so
      # it will stay in the RequestRouter process
      attr :session, true

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

      # params returns the request params
      def params
        @r.params
      end

      # save_session saves the session and cookie hashes back into the response
      def save_session(response)
        @env['rack.session'] = @session.dup
      end
    end
  end
end
