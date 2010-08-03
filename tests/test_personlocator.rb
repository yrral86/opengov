#!/usr/bin/env ruby1.9.1

require 'lib/testcase'
require 'lib/componenthelper'
require 'lib/types/person'
require 'nokogiri'

class OpenGovPersonLocatorTest < OpenGovTestCase
  def setup
    @ch = OpenGovComponentHelper.new
    super
  end

  def test_personlist
    get '/personlocator/person'
    doc = Nokogiri::HTML(last_response.body)
    records = @ch.get_model("PersonLocator::person").find(:all).length
    assert_equal records + 1, doc.css('a').length
  end

  def test_create_person
    person = {:fname => 'FirstNameForTestUser',
      :lname => 'LastNameForTestUser'}
    post '/personlocator/person', person
    assert_equal 302, last_response.status
    follow_redirects
    person_model = @ch.get_model("PersonLocator::person")
    p = person_model.find_by_lname(person[:lname])
    assert_equal "/personlocator/person/#{p.id}", last_request.path
    p.destroy
  end
end
