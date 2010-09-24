module Derailed
  module Manager
    # = Deraild::Manager::Daemon
    # This class handles controlling component processes.  As early as possible
    # in the Manager (to minimize copying unnecessary state), call
    # Daemon.create_spawner.  This will initialize the thread that spawns
    # components.  Then, for each component create an instance.  Then, you can
    # control the component with that instance.
    # === Example:
    #  static = Manager::Daemon.new('static')
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
    class Daemon
      attr_reader :name, :proxy

      def initialize(name)
        config = Config.component_config(name)
        @name = config['name']
      end

      # proxy= sets up the proxy for the component
      def proxy=(name)
        if name
          @proxy = Service.get name
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
        # wakeup spawneer, and pass until it sets @@to_start back to nil,
        # indicating it is done
        @@spawner.wakeup
        Thread.pass while @@to_start
        # set @pid to @@started, and set @@started back to nil
        @@started_mutex.synchronize do
          @pid = @@started
          @@started = nil
        end
        # wait until component has registered
        unless async
          sleep 0.05 until self.registered?
        end
        "Component #{@name} started [pid #{@pid}]"
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
            Process.waitpid(@pid)
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
        @@spawner = Thread.new do
          while true
            unless @@to_start
              Thread.stop
            else
              @@to_start_mutex.synchronize do
                name = @@to_start
                pid = fork do
                  require 'derailed'
                  component = Component::Daemon.new(name)
                  component.run
                end
                @@started_mutex.synchronize do
                  @@started = pid
                end
                @@to_start = nil
              end
            end
          end
          Thread.exit
        end
        # wait for spawner to initilize
        Thread.pass while !@@spawner.stop?
      end

      # running? returns true if the component is running, and false otherwise
      def running?
        begin
          if @pid
            Process.getpgid(@pid)
          else
            false
          end
        rescue
          false
        end
      end
    end
  end
end
