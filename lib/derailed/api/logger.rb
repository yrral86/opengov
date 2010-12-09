module Derailed
  module API
    module Logger
      # from Ruby Standard Library Logger
      def <<; end
      def debug; end
      def error; end
      def fatal; end
      def info; end
      def warn; end
      def debug?; end
      def error?; end
      def fatal?; end
      def info?; end
      def warn?; end
      # custom function for dumping backtraces
      def backtrace; end
    end
  end
end
