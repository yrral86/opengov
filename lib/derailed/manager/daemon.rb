module Derailed
  module Manager
    class Daemon
      def initialize(name)
        @name = name
      end

      def start
        # write name to class variable @@to_start, shared with spawner thread
        @@to_start_mutex.synchronize do
          @@to_start = @name
        end
        @@spawner.wakeup
        Thread.pass while @@to_start
        @@started_mutex.synchronize do
          @pid = @@started
          @@started = nil
        end
        # wait until component has registered
        sleep 0.05 until @@manager.is_registered?(@name)
        "Component #{@name} started [pid #{@pid}]"
      end

      def pid=(pid)
        @pid = pid
      end

      def stop
        if @pid
          Process.kill 'TERM', @pid
          Process.waitpid(@pid)
          @pid = nil
          "Component #{@name} stopped"
        else
          "Component #{@name} not running"
        end
      end

      def restart
        result = stop
        result += "\n#{start}"
      end

      def status
        "Component #{@name} " +
          (running? ? "running [pid #{@pid}]" : "not running")
      end

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

      private
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

      def self.wallit(msg)
#        `echo '#{msg}' | wall`
        puts msg
      end
    end
  end
end
