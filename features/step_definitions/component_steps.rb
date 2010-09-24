Given /^'(.*)' has '(.*)'$/ do |component, apis|
  pending
end

When /^I call '(.*)' on the DRbObject for '(.*)'$/ do |method, component|
  @return_value, @error = nil, nil
  begin
    @return_value = Derailed::Service.get(component).send method
  rescue => e
    @error = e
  end
end

Then /^the return value should contain each of '(.*)' methods$/ do |apis|
  assert @return_value, "no return value"
  apis.split(',').each do api
    last = api.split('::').last
    Derailed::Component::API.const_get(last).public_instance_methods.each do |m|
      assert @return_value.contains?(m)
    end
  end
end

Then /^the return value should contain each of '(.*)'$/ do |apis|
  assert @return_value, "no return value"
  apis.split(',').each do api
    assert @return_value.contains?(api)
  end
end

When /^I call each returned value on the DRbObject for '(.*)'$/ do |component|
  assert @return_value, "no return value"
  object = Derailed::Service.get(component)
  @return_value.each do |method|
    object.send method
  end
end

Then /^a random method sent to '<component>' gives an InvalidAPI error$/ do |c|
  assert @return_value, "no return value"
  component = Derailed::Service.get(c)
  rand(20).times do
    id = (3...rand(20)).map{ ('a'..'z').to_a[rand(26)] }.join.to_sym
    unless @return_value.contains?(id)
      have_error = catch(:success) do
        begin
          component.send id
        rescue Derailed::Component::InvalidAPI
          throw :success, true
        end
        false
      end
      assert have_error
    end
  end
end
