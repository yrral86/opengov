module Derailed
  module Manager
    ##
    # Feature: Allow Manager to control the component lifecycle
    #   As an administrator
    #   I want to issue a command to a running component
    #   And start components that are not running
    #   And register a component that is started by another process
    #   Later I want to be able to stop (sig STOP) a component
    #   And resume stopped components
    #   And takeover parentship of process started by another process
    ##
    module Components
      ##
      # Scenario Outline: issue a command to a running compnent
      #   Given '<component>' is running
      #   And '<component>' is registered
      #   When I send the manager '<command>' for '<component>'
      #   Then '<component>' should react to the '<command>'
      #
      #   Scenarios: Component Commands
      #     | component     | command  |
      #     | Static        | status   |
      #     | Debug         | running? |
      #     | PersonLocator | restart  |
      #     | Authenticator | stop     |
      #     | Ajax          | apis     |
      #     | Map           | status   |
      #
      # Scenario Outline: start components that are not running
      #   Given '<component>' is not running
      #   When I run './control.rb -c <component> start'
      #   Then '<component>' is running
      #
      #   Scenarios: Components
      #     | component     |
      #     | Static        |
      #     | Debug         |
      #     | PersonLocator |
      #     | Authenticator |
      #     | Ajax          |
      #     | Map           |
      ##
      def component_command(component, command, async = false)
        component = component_by_lowercase_name(component)
        if command == 'start'
          component.send command, async
        else
          component.send command
        end
      end

      ##
      # Scenario Outline: register a component that is started externally
      #   Given '<component>' is not running
      #   When I run './control.rb -c <component> run' asynchronously
      #   Then '<component>' is running
      #
      #   Scenarios: Components
      #     | component     |
      #     | Static        |
      #     | Debug         |
      #     | PersonLocator |
      #     | Authenticator |
      #     | Ajax          |
      #     | Map           |
      ##
      def component_pid(component, pid)
        component_by_lowercase_name(component).pid = pid
      end

      private
      # init_component creates a new Manager::Daemon for the component
      # and adds it to the @daemons array
      def init_component(component)
        daemon = Daemon.new(component)
        @daemons[daemon.name] = daemon
      end

      # component_by_lowercase_name returns the component who's downcased name
      # matches the name passed in
      def component_by_lowercase_name(name)
        @daemons.each_key do |k|
          return @daemons[k] if k.downcase == name
        end
        nil
      end
    end
  end
end
