Given /^I log in using '(\S+)' and '(\S+)'$/ do |username, password|
  visit '/login'
  fill_in "user_session[username]", :with => username
  fill_in "user_session[password]", :with => password
  click_button "login"
end

Given /^I am logged in as '(\S+)'$/ do |username|
  visit '/home'
  assert_contain "logged in username: #{username}"
end

Given /^I go to '(\S+)'$/ do |url|
  visit url
end

Given /^I am at '(\S+)'$/ do |url|
  assert_equal url, last_request.path
end
