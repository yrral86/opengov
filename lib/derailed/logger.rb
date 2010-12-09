require 'logger'

module Derailed
  class Logger < ::Logger
    def initialize(name, server=false)
      @server = server
#   we aren't actually using these anywhere yet, but caching would be
#   very beneficial in this case
#      unless server
#        @procs = {}
#        @cache = {}

#        [
#         :debug?,
#         :error?,
#         :fatal?,
#         :info?,
#         :warn?
#        ].each do |query|
          # cache results of ? queries on client
#          @procs[query] = proc {@cache[query] ||= @logger.__send__(query)}
#        end
#      end

# also, we need to check log level on each call to debug, error, etc.

      init = proc do
        if Config::Environment == 'testing'
          STDERR
        elsif server
          super(Logger.log_file(name),
                Config::LoggerShiftAge, Config::LoggerShiftSize)
        else
          @logger = Service.get_logger
        end
      end

      $stderr = init.call
    end

    def puts(msg)
      @puts_proc ||= (@server ? proc{|msg| self << msg} :
                      proc{|msg| @logger << msg})
      @puts_proc.call msg
    end

    alias :write :puts
    def flush; self; end

    def backtrace(error)
      @bt_proc ||= (@server ? proc do |error|
                      self << error
                      self << error.backtrace.join("\n")
                    end :
                    proc{ |error| @logger.backtrace error })
      @bt_proc.call error
    end

    # log_file returns the filename of the component or Manager's log
    def self.log_file(name)
      name = name.camelize
      "#{Config.log_dir}/#{name}.log"
    end
  end
end
