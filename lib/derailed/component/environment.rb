module Derailed
  module Component
    # = Derailed::Component::Environment
    # This module provides convenience functions to interact with the
    # Derailed::RequestRouter side controller (Derailed::RackApp::Controller)
    module Environment
      private

      def env
        Thread.current[:env]
      end

      # session extracts the session from the controller.
      # It will be a DRb object that is interacted with
      # over the socket
      def session
        env['rack.session']
      end

      # params extracts the params from the controller.
      # It will be copied
      def params
        request.params
      end

      # path(n) gets the nth string of the path, split by /
      # ===== example: /extra/long/test/path/
      # path(0):: ''
      # path(1):: 'extra'
      # path(2):: 'long'
      # path(3):: 'test'
      # path(4):: 'path'
      def path(n)
        Thread.current[:paths][n]
      end

      # next_path gets the next portion of the path
      # ===== example: /extra/long/test/path/
      # 1st call:: 'extra'
      # 2nd call:: 'long'
      # 3rd call:: 'test'
      # 4th call:: 'path'
      def next_path
        Thread.current[:path_queue].shift
      end

      # full_path returns the full request path
      def full_path
        request.path
      end

      def request
        env['rack.request']
      end
    end
  end
end
