When /^I create a person '(.*)' via PersonLocator/ do |name|
  first, last = name.split
  visit '/personlocator/person/edit'
  fill_in 'fname', :with => first
  fill_in 'lname', :with => last
  click_button 'Update'
end

Given /^there are people records in PersonLocator$/ do
  rand(10).times {post '/personlocator/person',
    {:fname => "FirstName#{rand(100)}",
      :lname => "LastName#{rand(100)}"}}
end
