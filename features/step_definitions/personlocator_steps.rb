When /^I create a person '(.*)' via PersonLocator$/ do |name|
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

Then /^I am viewing the details of person '(.*)' via PersonLocator$/ do |lname|
  person = @cc.get_model('PersonLocator::Person').find_by_lname(lname)
  Then "I am at '/personlocator/person/#{person[:id]}'"
  And "I should see '#{person[:fname]}'"
  And "I should see '#{person[:lname]}'"
  And "the HTML should contain " +
    "'a[href=\"/personlocator/person/edit/#{person[:id]}\"]'"
  And "the HTML should contain " +
    "'a[href=\"/personlocator/person\"]'"
  And "the HTML should contain 'a[href=\"javascript:delete_object('" +
    "#{person[:id]}','/personlocator/person')\"]'"
end
