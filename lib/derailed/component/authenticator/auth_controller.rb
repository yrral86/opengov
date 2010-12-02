module Derailed
  module Component
    class AuthController
      include Environment

      def cookies
        return @c if @c
        c = request.cookies
        def c.delete(key, options = {})
          super(key)
        end
        @c = c
      end

      # Disable http_basic authentication
      def authenticate_with_http_basic
        false
      end

      # cookie_domain returns the HTTP_HOST header, which will be used to
      # set the domain for cookies (required by Authlogic)
      def cookie_domain
        env['HTTP_HOST']
      end
    end
  end
end
