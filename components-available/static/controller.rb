#dir = File.expand_path(File.dirname(__FILE__))
#require dir + '/../../lib/derailed'

class StaticController < Derailed::Component::Controller
  def test_method
    Derailed::Component::View.render_string "Yo"
  end

  def javascript
    path = "#{Derailed::Config::RootDir}/javascript/#{next_path}"
    render_path(path)
  end

  def images
    path = "#{Derailed::Config::RootDir}/images/#{next_path}"
    render_path(path)
  end

  private
  def render_path(path)
    file = File.read path
    render_string file
  end

  def next_path
    'prototype.js'
  end
end
