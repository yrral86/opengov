Given /^I create a person '(.*)' via PersonLocator/ do |name|
  first, last = name.split
  visit '/personlocator/person/edit'
  fill_in 'fname', :with => first
  fill_in 'lname', :with => last
  click_button 'Update'
end
