Given /^(.*) is (.*)running$/ do |component, negate|
  pending
  running = @client.manager.component_command(component, 'running?')
  assert (negate == 'not ' ? !running : running)
end

Given /^<component> is (.*)registered$/ do |negate|
  pending
end

Then /^<component> should react to the <command>$/ do
  pending
end
