When /^I go to '(.*)'$/ do |url|
  visit url
end

When /^I inspect the body$/ do
  puts last_response.body
end

Then /^I am at '(.*)'$/ do |url|
  assert_equal url, last_request.path
end

Then /^I should see '(.*)'$/ do |message|
  assert_contain message
end

Then /^the HTML should contain '(.*)'$/ do |selector|
  assert_have_selector selector
end

Then /^there should be one more row than '(.*)' records$/ do |model|
  records = Derailed::Service.get_model(model).find(:all).length
  nodes = Nokogiri::HTML(last_response.body).css('tr').length
  assert_equal nodes, records + 1,
  "There are #{nodes} nodes and #{records} records"
end

When /^I run '(.*)'(.*)$/ do |command, sync|
#  debug "I run '#{command}'#{sync}"
  if sync == ' asynchronously'
    Process.detach(fork {exec "#{command} 2>/dev/null"})
    sleep 1
  else
    `#{command}`
  end
end
