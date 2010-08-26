require 'rack'
require 'drb'

dir = File.expand_path(File.dirname(__FILE__))

[
 'cookiefix',
 'controller'
].each do |library|
  require "#{dir}/#{library}"
end

module Derailed
  module Controller
    class Base
      def initialize(app)
        @app = app
        @ch = ComponentHelper.new
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
          path = env[:controller].request.path
          env[:controller].session[:onlogin] = path unless path == '/favicon.ico'
          Component::View.redirect('/login')
        end
      end

      def load_parser(env)
        env[:controller] = Controller.new(env)
      end

      def commit_parser(env, status, headers, body)
        response = Rack::Response.new(body, status, headers)
        env[:controller].save_session(response)
        [status, headers, body]
      end
    end
  end
end
