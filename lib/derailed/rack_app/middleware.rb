require 'rack'

require 'derailed/logger'

module Derailed
  module RackApp
    # = Derailed::RackApp::Middleware
    # This class provides a Rack middleware that adds a
    # Derailed::RackApp::Controller to the env variable and ensures
    # a user is logged in for any url other than /login
    class Middleware
      # initialize sets the app and creates a Client
      def initialize(app)
        @logger = Logger.new 'RackAppMiddleware'
        @app = app
      end

      # call adds the controller, calls the app, and commits the changes
      # to the session and cookies via commit_controller which returns the
      # response
      def call(env)
        load_controller(env)
        status, headers, body = authenticate(env) do |env|
          @app.call(env)
        end
        commit_controller(env, status, headers, body)
      end

      private

      # authenticate enforces authentication for all urls other than /login.
      # If there is no logged in user, any other url is stored for redirecting
      # after login, and the user is redirected to the login form.
      def authenticate(env)
        @authenticator ||= Service.get 'Authenticator'

        # fetch current session
        begin
          current_session = @authenticator.current_session(env)
        rescue => e
          @logger.backtrace e.backtrace
        end

        if env['rack.request'].path == '/login' or current_session
          yield env
        else
          path = env['rack.request'].path
          env['rack.session'][:onlogin] =
            path unless path == '/favicon.ico'
          Component::View.redirect('/login')
        end
      end

      # load_controller creates a RackApp::Controller for the request
      def load_controller(env)
        env['rack.session'].extend(DRbUndumped)
        env['rack.request'] = Rack::Request.new(env)
        env[:paths] = env['rack.request'].path.split '/'
        env[:path_queue] = Array.new env[:paths]
        # The first element is blank
        env[:path_queue].shift
      end

      # commit_controller saves the session/cookies and returns the response
      def commit_controller(env, status, headers, body)
        # copy rack.session to new hash to get rid of DRbUndumped
        env['rack.session'] = env['rack.session'].dup
        [status, headers, body]
      end
    end
  end
end
