Given /^I go to '(.*)'$/ do |url|
  visit url
end

Given /^I am at '(.*)'$/ do |url|
  assert_equal url, last_request.path
end

Given /^I should see '(.*)'$/ do |message|
  assert_contain message
end
