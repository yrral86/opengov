module Derailed
  module Component
    module Authentication
      def setup_env(env)
        Thread.current[:env] = env
        Authlogic::Session::Base.controller = controller
      end

      def current_session
        @ch.get_current_session(Thread.current[:env])
      end

      def current_user
        s = current_session
        s && s.record
      end
    end
  end
end
