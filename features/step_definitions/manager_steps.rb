Given /^'(.*)' is (.*)running$/ do |component, negate|
  client = proc {|a| @client.manager.component_command(component.downcase,a)}
  client.call('stop') if negate == 'not '

  running = client.call('running?')
  assert (negate == 'not ' ? !running : running),
  "#{component} is #{negate}running is false"
end

Given /^'(.*)' is (.*)registered$/ do |component, negate|
  pending
end

Then /^'(.*)' should react to the '(.*)'$/ do |component, command|
  pending
end
