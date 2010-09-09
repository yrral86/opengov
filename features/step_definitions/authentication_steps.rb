Given /^I go to '(\S+)'$/ do |url|
  visit url
end

Given /^I login with '(\S+)' and '(\S+)'$/ do |username, password|
  fill_in "user_session[username]", :with => username
  fill_in "user_session[password]", :with => password
  click_button "login"
end

Then /^I should be logged in as '(\S+)'$/ do |username|
  assert_contain "logged in username: #{username}"
end
