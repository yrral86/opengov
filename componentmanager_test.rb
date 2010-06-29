#!/usr/bin/env ruby1.9.1

require 'test/unit'
require 'lib/componenthelper'

class OpenGovComponentManagerTest < Test::Unit::TestCase
  def setup
    `./componentmanager.rb start`
    @webserver = fork do
      exec 'rackup router.ru -p 3000'
    end
    sleep 5 # give the webserver time to start
    `./components/static.rb start` # required by PersonLocator
    sleep 1 # give the daemons time to start and register themselves
    `./components/personlocator.rb start`
    sleep 1 # give the daemons time to start and register themselves
    @ch = OpenGovComponentHelper.new
  end

  def teardown
    # if an assert fails, make sure we shut down
    `./components/personlocator.rb stop`

    `./components/static.rb stop`

    # should kill all components, but not working yet
    `./componentmanager.rb stop`

    Process.kill("KILL", @webserver)
    `rm /tmp/opengovrequestrouter.sock`
  end

  def test_components_register_unregister
    assert_equal(
                 ['PersonLocator::address','PersonLocator::person'],
                 @ch.cm.available_models.sort
                 )

    person = @ch.get_model("PersonLocator::person")

    larry = person.new(:fname => 'Larry', :lname => 'Reaves')
    larry.save

    assert_equal('Larry', person.find_by_lname('Reaves').fname)

    larry.delete
     
    `./components/personlocator.rb stop`
    assert_equal('', @ch.cm.available_models.join(''))
  end
end
