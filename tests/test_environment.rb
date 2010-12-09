#!/usr/bin/env ruby

require 'test/unit'

class OpenGovEnvironmentTest < Test::Unit::TestCase
  def test_system_packages
    packages = File.read('requirements/packages').split "\n"
    packages.each do |p|
      unless p == ""
        assert_equal "6", `dpkg -l #{p} |wc -l`.chomp,
        "Package #{p} not installed"
      end
    end
  end

  def test_gem_packages
    assert_equal "The Gemfile's dependencies are satisfied\n", `bundle check`
  end
end
