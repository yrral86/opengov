module Derailed
  module Component
    # = Derailed::Component::Environment
    # This module provides convenience functions to interact with the
    # Request and the Derailed::RackApp side session
    module Environment
      # env fetches the thread local variable set in aetup_env
      def env
        Thread.current[:env]
      end

      # session extracts the session from the environment
      # It will be a DRb object that is interacted with
      # over the socket
      def session
        request.session
      end

      # params extracts the params from the request
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
        env[:paths][n]
      end

      # next_path gets the next portion of the path
      # the RequestRouter consumes the first portion
      # ===== example: /extra/long/test/path/
      # 1st call:: 'long'
      # 2nd call:: 'test'
      # 3rd call:: 'path'
      def next_path
        # copy the array, shift and copy back
        # for some reason, env[:path_queue].shift doesn't remove the element
        a = env[:path_queue].dup
        p = a.shift
        env[:path_queue] = a
        p
      end

      # full_path returns the full request path
      def full_path
        request.path
      end

      # request extracts the request from the environment
      def request
        env['rack.request']
      end
    end
  end
end
