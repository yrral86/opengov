Given /^'(.*)' is (.*)running$/ do |component, negate|
  running = @client.manager.component_command(component.downcase, 'running?')
  assert (negate == 'not ' ? !running : running)
end

Given /^<component> is (.*)registered$/ do |negate|
  pending
end

Then /^<component> should react to the <command>$/ do
  pending
end
