#!/usr/bin/env ruby1.9.1

require 'debian'
require 'test/unit'

class OpenGovEnvironmentTest < Test::Unit::TestCase
  def test_system_packages
    packages = File.read('requirements/packages').split "\n"
    packages.each do |p|
      unless p == "" then
        package = Debian::Dpkg.status([p]).packages[0]
        assert package, "System package " + p + " not installed"
        assert_equal "installed",
        package.status
        "System package " + p + " not installed"
      end
    end
  end

  def test_gem_packages
    gems = File.read('requirements/rubypackages').split "\n"
    gems.each do |g|
      unless g == "" then
        assert not(Gem.source_index.find_name(g).empty?), "Gem " + g + " not installed"
      end
    end
  end
end
