module Derailed
  class Logger < ::Logger
    def initialize(name)
      super(log_file(name), Config::LoggerShiftAge, Config::LoggerShiftSize)
    end

    # log_file returns the filename of the component or Manager's log
    def self.log_file(name)
      name = name.camelize
      "#{Config.log_dir}/#{name}.log"
    end
  end
end
