Given /^I am logged in as '(.*)'$/ do |username|
  visit '/home'
  assert_contain "logged in username: #{username}"
end

When /^I log out$/ do
  visit '/logout'
end

When /^I log in using '(.*)' and '(.*)'$/ do |username, password|
  visit '/login'
  fill_in 'user_session[username]', :with => username
  fill_in 'user_session[password]', :with => password
  click_button 'login'
end

When /^I create a user '(.*)' with password '(.*)'$/ do |username, password|
  visit '/newuser'
  fill_in 'user[username]', :with => username
  fill_in 'user[password]', :with => password
  fill_in 'user[password_confirmation]', :with => password
  click_button 'submit'
end
