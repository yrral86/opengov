require 'logger'

module Derailed
  class Logger < ::Logger
    def initialize(name)
      $stderr = self

      init = proc do
        super(Logger.log_file(name),
              Config::LoggerShiftAge, Config::LoggerShiftSize)
      end

      case Config::Environment
      when 'production'
        init.call
      when 'testing'
        # no need to log testing... if the tests fail we debug in development
        # or, we change this
        nil
      when 'development'
        init.call
      end
    end

    alias :puts :error
    alias :write :error
    def flush; self; end

    def backtrace(stack)
      stack.each do |call|
        self.error(call)
      end
    end

    # log_file returns the filename of the component or Manager's log
    def self.log_file(name)
      name = name.camelize
      "#{Config.log_dir}/#{name}.log"
    end
  end
end
