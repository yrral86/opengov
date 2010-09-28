Given /^'(.*)' is (.*)running$/ do |component, negate|
#  debug "'#{component}' is #{negate}running"
  client = proc {|a| @manager.component_command(component.downcase,a)}
  client.call('stop') if negate == 'not '

  running = client.call('running?')
  assert (negate == 'not ' ? !running : running),
  "#{component} is #{negate}running is false"
end

Given /^'(.*)' is (.*)registered$/ do |component, negate|
#  debug "'#{component}' is #{negate}registered"
  result = send_component_command(component, 'registered?')
  assert (negate == 'not ' ? !result : result)
end

Then /^'(.*)' should react to the '(.*)'$/ do |component, command|
#  debug "'#{component}' should react to the '#{command}'"
  case command
  when 'apis'
    assert_equal Derailed::Service.get(component).apis, @result
  when 'registered?'
    assert @result
  when 'restart'
    result = @result
    send_component_command(component, 'pid')
    assert "Component #{component} stopped\n" +
      "Component #{component} started [pid #{@result}]", result
  when 'running?'
    result = @result
    send_component_command(component, 'pid')
    assert_equal @result, result
  when 'status'
    result = @result
    send_component_command(component, 'pid')
    assert_equal "Component #{component} running [pid #{@result}]", result
  when 'stop'
    assert_equal "Component #{component} stopped", @result
    send_component_command(component, 'status')
    assert_equal "Component #{component} not running", @result
    send_component_command(component, 'start')
  end
end

When /^I send the manager '(.*)' for '(.*)'$/ do |command, component|
#  debug "I send the manager '#{command}' for '#{component}'"
  send_component_command(component, command)
end
