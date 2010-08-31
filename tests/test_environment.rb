#!/usr/bin/env ruby

#require 'debian'
require 'test/unit'

class OpenGovEnvironmentTest < Test::Unit::TestCase
  def test_system_packages
    assert false, "can not test system packages with enterprise ruby, make " +
      "sure you run 'sudo apt-get install `cat requirements/packages`'"
  end
#  def test_system_packages
#    packages = File.read('requirements/packages').split "\n"
#    packages.each do |p|
#      unless p == "" then
#        package = Debian::Dpkg.status([p]).packages[0]
#        assert package, "System package " + p + " not installed"
#        assert_equal "installed",
#        package.status
#        "System package " + p + " not installed"
#      end
#    end
#  end

  def test_gem_packages
    gems = File.read('requirements/rubypackages').split "\n"
    gems.each do |g|
      unless g == "" then
        assert Gem.source_index.find_name(g).empty? == false, "Gem " + g + " not installed"
      end
    end
  end
end
