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
end
