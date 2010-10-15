Given /^I am testing '(.*)'$/ do |api|
  obj = Object.new
  def obj.method_missing(id,*args)
    true
  end
  def obj.authorized_methods(key,public_methods,manager_methods)
    manager_methods
  end
  base = Derailed::API::Base
  @api_object = Derailed::ServedObject.new(obj, 'key_for_testing', [base])
  api = api.split('::')[1]
  unless api == 'Base'
    const = Derailed::API.const_get(api)
    @api_object.register_api('key_for_testing',const)
  end
  name = 'CucumberTestObject'
  Derailed::Service.start(name, @api_object)
  @proxy_object = Derailed::Proxy.new(Derailed::Socket.uri(name))
end

After do
  if @api_object
    Derailed::Service.stop
    @api_object = nil
    @proxy_object = nil
  end
end

Given /^the object implements '(.*)'$/ do |api|
  const = Derailed::API.const_get(api)
  @api_object.register_api('key_for_testing',const)
end

Given /^the results should include \[(.*)\]$/ do |list|
  pending
end

Given /^the object proxies '(.*)'$/ do |name|
  pending
end

When /^I call object\.(.*)$/ do |id|
  if id =~ /(.*)\((.*)\)/
    id = $1.to_sym
    args = $2
  else
    id = id.to_sym
    args = []
  end
  puts "calling #{id} on object with args #{args}"
  begin
    @proxy_object.__send__ id, *args
    @invalid_api = false
  rescue Derailed::InvalidAPI
    @invalid_api = true
  rescue NoMethodError => e
    puts e.backtrace
  end
end

Given /^'(.*)' is trying to access it$/ do |name|
  pending
end

Then /^the object should (.*)throw InvalidAPI$/ do |negate|
  if negate == "not "
    assert !@invalide_api
  else
    assert @invalid_api
  end
end

