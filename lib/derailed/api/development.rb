module Derailed
  module API
    module Development
      include API::Testing
      def debug; end
    end
  end
end
