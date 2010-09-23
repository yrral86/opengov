require 'rack'

require "derailed/controller/controller"

module Derailed
  module Controller
    # = Deraild::Controller::Middleware
    # This class provides a Rack middleware that adds a
    # Derailed::Controller::Controller to the env variable and ensures
    # a user is logged in for any url other than /login
    class Middleware
      # initialize sets the app and creates a ComponentClient
      def initialize(app)
        @app = app
        @cc = ComponentClient.new
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
        if @cc.get_current_session(env) or
            env[:controller].request.path == '/login'
          yield env
        else
          path = env[:controller].request.path
          env[:controller].session[:onlogin] =
            path unless path == '/favicon.ico'
          Component::View.redirect('/login')
        end
      end

      # load_controller creates a Controller::Controller for the request
      def load_controller(env)
        env[:controller] = Controller.new(env)
      end

      # commit_controller saves the session/cookies and returns the response
      def commit_controller(env, status, headers, body)
        response = Rack::Response.new(body, status, headers)
        env[:controller].save_session(response)
        [status, headers, body]
      end
    end
  end
end
