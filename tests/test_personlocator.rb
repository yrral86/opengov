#!/usr/bin/env ruby

require 'derailed/testcase'
require 'nokogiri'

class OpenGovPersonLocatorTest < Derailed::TestCase
  def test_personlist
    rand(10).times {post '/personlocator/person', fake_person}
    get '/personlocator/person'
    doc = Nokogiri::HTML(last_response.body)
    records = @client.get_model("PersonLocator::Person").find(:all).length
    assert_equal records + 1, doc.css('tr').length
  end

  def test_create_person
    person = fake_person
    post '/personlocator/person', person
    assert_equal 302, last_response.status
    follow_redirects
    person_model = @client.get_model("PersonLocator::Person")
    p = person_model.find_by_lname(person[:lname])
    assert_equal "/personlocator/person/#{p[:id]}", last_request.path
    p.destroy
  end

  def test_create_destroy_person
    person = fake_person
    post '/personlocator/person', person
    params = person.dup
    params['_method'] = 'delete'
    follow_redirects
    id = last_request.path.split('/')[3]
    person_model = @client.get_model("PersonLocator::Person")
    p = person_model.find_by_id(id)
    assert_equal person[:fname], p.fname
    post "/personlocator/person/#{id}", params
    p = person_model.find_by_id(id)
    assert_equal nil, p
  end

  def fake_person
    {:fname => 'FirstNameForTestUser',
      :lname => 'LastNameForTestUser'}
  end
end
