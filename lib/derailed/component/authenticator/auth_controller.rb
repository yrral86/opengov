module Derailed
  module Component
    class AuthController
      def initialize
        @env = Thread.current[:env]
        @r = Rack::Request.new(@env)
      end

      def session
#        @r.session
        @env[:controller].session
      end

      def cookies
        return @c if @c
        c = @r.cookies
        def c.delete(key, options = {})
          super(key)
        end
        @c = c
      end

      # Disable http_basic authentication
      def authenticate_with_http_basic
        false
      end

      def params
        @r.params
      end

      # cookie_domain returns the HTTP_HOST header, which will be used to
      # set the domain for cookies (required by Authlogic)
      def cookie_domain
        @env['HTTP_HOST']
      end
    end
  end
end
