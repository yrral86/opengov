require 'derailed/served_object'
require 'active_support/core_ext'

module Derailed
  module Manager
    # = Deraild::Manager::Component
    # This class handles controlling component processes.  As early as possible
    # in the Manager (to minimize copying unnecessary state), call
    # Component.create_spawner.  This will initialize the thread that spawns
    # components.  Then, for each component create an instance.  Then, you can
    # control the component with that instance.
    # === Example:
    #  static = Manager::Component.new('static')
    #  static.status
    #  > Component static not running
    #  static.start
    #  > Component static started [pid 12345]
    #  static.status
    #  > Component static running [pid 12345]
    #  static.stop
    #  > Component static stopped
    #  static.status
    #  > Component static not running
    class Component
      attr_reader :name, :proxy, :pid

      def initialize(name, manager)
        config = Config.component_config(name)
        @name = config['name']
        @manager = manager
      end

      def died(exiting)
        # unregister component
        @manager.unregister_component @name

        # clean up socket
        sock = Socket.path @name
        File.unlink sock if File.exists? sock

        # restart unless we are exiting manager
        auto_restart unless exiting
      end

      def auto_restart
        # TODO: notify admin
        unless @restarts
          @restarts = 1
          @restart_time = Time.now
          start
        else
          if @restarts < 5
            sleep 1
            @restarts += 1
            start
          elsif Time.now - @restart_time < 1.minute
            puts "Restart failed 5 times, waiting 1 minute to try again"
          else
            @restarts = nil
          end
        end
      end

      # proxy= sets up the proxy for the component
      def proxy=(name)
        if name
          @proxy = Service.get name
          @@starter.wakeup if @@starter
        else
          @proxy = nil
        end
      end

      # registered? tests whether the component is registered
      def registered?
        @proxy ? true : false
      end

      # start sets @@to_start to the name of the component to start and
      # wakes up @@spawner, waits for it to finish, and then sets @pid
      def start(async = false)
        # write name to class variable @@to_start, shared with spawner thread
        @@to_start_mutex.synchronize do
          @@to_start = @name.downcase
        end
        # wakeup spawner so it can run when we sleep
        @@spawner.wakeup
        # spawner will wake up this thread after it spawns the component
        @@starter = Thread.current
        Thread.stop
        # set @pid to @@started, and set @@started back to nil
        @@started_mutex.synchronize do
          @pid = @@started
          @@started = nil
        end
        unless async
          # wait up to MaxComponentStart seconds for component to start,
          # proxy= will wake us when the component registers itself
          sleep Config::MaxComponentStart
        end
        @@starter = nil
        if self.registered?
          "Component #{@name} started [pid #{@pid}]"
        else
          "Component #{@name} failed to start, please check the log file " +
            "for more information"
        end
      end

      # pid= sets the pid... this is used when the component is run in the
      # control process via the run command
      def pid=(pid)
        @pid = pid
      end

      # stop kills the process
      def stop
        if @pid
          begin
            Process.kill 'TERM', @pid
            # we don't need to wait as we handle sig CHLD
          rescue Errno::ECHILD
            puts "figure out how to take ownership of processes started " +
              "externally"
          end
          @pid = nil
          "Component #{@name} stopped"
        else
          "Component #{@name} not running"
        end
      end

      # restart stops, then starts the component
      def restart
        result = stop
        result += "\n#{start}"
      end

      # status returns a string containing the status of the component
      def status
        "Component #{@name} " +
          (running? ? "running [pid #{@pid}]" : "not running")
      end

      # self.create_spawner creates the spawner thread for spawning
      # component processes
      def self.create_spawner(manager)
        @@manager = manager
        @@to_start = nil
        @@started = nil
        @@to_start_mutex = Mutex.new
        @@started_mutex = Mutex.new
        init_thread = Thread.current
        first = true
        @@spawner = Thread.new do
          while true
            unless @@to_start
              if first
                first = false
                init_thread.wakeup
              end
              Thread.stop
            else
              @@to_start_mutex.synchronize do
                name = @@to_start
                old_stderr = $stderr
                $stderr = STDERR
                pid = fork do
                  ObjectSpace.each_object(IO) do |io|
                    unless [STDIN, STDOUT, STDERR].include?(io)
                      io.close rescue nil
                    end
                  end
                  exec "#{Config::ControlScript} -rc #{name}"
                end
                $stderr = old_stderr
                @@started_mutex.synchronize do
                  @@started = pid
                end
                @@to_start = nil
                @@starter.wakeup
              end
            end
          end
          # exit! so we don't call at_exit
          Thread.exit!
        end
        # wait for spawner to initilize
        Thread.stop
      end

      # running? returns true if the component is running, and false otherwise
      def running?
        if @pid
          begin
            Process.getpgid @pid
            @pid
          rescue Errno::ESRCH
            false
          end
        else
          false
        end
      end

      def method_missing(id, *args)
        begin
          if @proxy
            @proxy.__send__(id, *args)
          else
            "component not registered"
          end
        rescue InvalidAPI
          "invalid command"
        end
      end
    end
  end
end
