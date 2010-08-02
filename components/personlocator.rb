#!/usr/bin/env ruby1.9.1

dir = File.expand_path(File.dirname(__FILE__))

require dir + '/../lib/component'
require dir + '/personlocator/m/person'
require dir + '/personlocator/m/address'

class OpenGovPersonLocatorComponent < OpenGovComponent
  def call(env)
    super(env, false)
    puts current_user.username
    crud(env)
  end
end

Daemons.run_proc('OpenGovPersonLocatorComponent',
                 {:dir_mode => :normal, :dir => dir}) do
  OpenGovPersonLocatorComponent.new(
                                    'PersonLocator',
                                    [Person, Address],
                                    [],
                                    ['Static']
                                    ).daemonize
end
