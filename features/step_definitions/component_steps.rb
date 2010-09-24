Given /^'(.*)' has '(.*)'$/ do |component, test_apis|
  hash = {}
  Derailed::Service.get(component).apis.each do |api|
    hash[api.split('::')[3]] = true
  end

  test_apis.split(',').each do |test_api|
    assert hash[test_api]
  end
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
  hash = {}
  @return_value.each { |value| hash[value] = true }
  apis.split(',').each do |api|
    Derailed::Component::API.const_get(api).public_instance_methods.each do |m|
      assert hash[m]
    end
  end
end

Then /^the return value should contain each of '(.*)'$/ do |apis|
  assert @return_value, "no return value"
  hash = {}
  @return_value.each { |v| hash[v.split('::')[3]] = true }
  apis.split(',').each do |api|
    assert hash[api]
  end
end

When /^I call each returned value on the DRbObject for '(.*)'$/ do |component|
  assert @return_value, "no return value"
  object = Derailed::Service.get(component)
  @return_value.each do |method|
    no_error = catch(:fail) do
      begin
        object.send method
      rescue ArgumentError
      rescue Derailed::Component::InvalidAPI
        throw :faile, false
      end
      true
    end
    assert no_error
  end
end

When /^a random method sent to '(.*)' gives an InvalidAPI error$/ do |c|
  assert @return_value, "no return value"
  component = Derailed::Service.get(c)
  hash = {}
  @return_value.each { |v| hash[v] = true }
  rand(20).times do
    id = (3...rand(20)).map{ ('a'..'z').to_a[rand(26)] }.join.to_sym
    unless hash[id]
      have_error = catch(:success) do
        begin
          component.send id
        rescue Derailed::Component::InvalidAPI
          throw :success, true
        end
        false
      end
      assert have_error, "Failed with id = #{id}"
    end
  end
end
