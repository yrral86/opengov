Given /^'(.*)' is (.*)running$/ do |component, negate|
#  debug "'#{component}' is #{negate}running"
  client = proc {|a| @client.manager.component_command(component.downcase,a)}
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
    pending
  when 'registered?'
    pending
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

def send_component_command(component, command)
  manager = Derailed::Service.get('Manager')
  @result = manager.component_command(component.downcase,command)
end

def debug(message)
  result = @result
  send_component_command('debug_message', message)
  @result = result
end
