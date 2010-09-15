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

Then /^I see the details of person '(.*)' via PersonLocator$/ do |name|
  person = person_record_from_full_name(name)
  Then "I am at '/personlocator/person/#{person[:id]}'"
  And "I should see '#{person[:fname]}'"
  And "I should see '#{person[:lname]}'"
  assert_have_link_to "/personlocator/person/edit/#{person[:id]}"
  assert_have_link_to "/personlocator/person"
  assert_have_link_to "javascript:delete_object(" +
    "'#{person[:id]}','/personlocator/person')"
end

When /^I delete '(.*)' via PersonLocator$/ do |name|
  person = person_record_from_full_name(name)
  if Webrat.configuration.mode == :rack
    params = {:fname => person[:fname],
      :lname => person[:lname], :_method => :delete}
    post "/personlocator/person/#{person[:id]}", params
  else  # we have selenium (js support)
    visit "/personlocator/person/#{person[:id]}"
    click_link 'Delete'
  end
end

Then /^there is no person named '(.*)' via PersonLocator$/ do |name|
  person = person_record_from_full_name(name)
  assert_equal nil, person
end

When /^I rename '(.*)' to '(.*)' via PersonLocator$/ do |original, new|
  new = new.split
  person = person_record_from_full_name(original)
  visit "/personlocator/person/#{person[:id]}"
  click_link "Edit"
  fill_in 'fname', :with => new[0]
  fill_in 'lname', :with => new[1]
  click_button 'Update'
end
