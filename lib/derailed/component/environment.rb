module Derailed
  module Component
    # = Derailed::Component::Environment
    # This module provides convenience functions to interact with the
    # Derailed::RequestRouter side controller (Derailed::Controller::Controller)
    module Environment
      private

      # controller extracts the controller from the environment for the current
      # thread (set in Derailed::Component::Authentication.setup_env)
      def controller
        Thread.current[:env][:controller]
      end

      # session extracts the session from the controller.
      # It will be a DRb object that is interacted with
      # over the socket
      def session
        controller.session
      end

      # params extracts the params from the controller.
      # It will be copied
      def params
        controller.params
      end

      # path(n) gets the nth string of the path, split by /
      # ===== example: /extra/long/test/path/
      # path(0):: ''
      # path(1):: 'extra'
      # path(2):: 'long'
      # path(3):: 'test'
      # path(4):: 'path'
      def path(n)
        controller.path(n)
      end

      # next_path gets the next portion of the path
      # ===== example: /extra/long/test/path/
      # 1st call:: 'extra'
      # 2nd call:: 'long'
      # 3rd call:: 'test'
      # 4th call:: 'path'
      def next_path
        controller.next
      end
    end
  end
end
