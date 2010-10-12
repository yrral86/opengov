require 'logger'

module Derailed
  class Logger < ::Logger
    def initialize(name)
      case Config::Environment
      when 'production'
        # disable logging in production
        # we may want to just turn down the log level
        # and probably put the logs in the right place
        nil
      when 'testing'
        # no need to log testing... if the tests fail we debug in development
        # or, we change this
        nil
      when 'development'
        super(Logger.log_file(name),
              Config::LoggerShiftAge, Config::LoggerShiftSize)
      end
    end

    # log_file returns the filename of the component or Manager's log
    def self.log_file(name)
      name = name.camelize
      "#{Config.log_dir}/#{name}.log"
    end
  end
end
