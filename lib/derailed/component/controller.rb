module Derailed
  module Component
    module Controller
      def controller
        Thread.current[:env][:controller]
      end

      def session
        controller.session
      end

      def params
        controller.params
      end

      def path(n)
        controller.path(n)
      end

      def next_path
        controller.next
      end
    end
  end
end
