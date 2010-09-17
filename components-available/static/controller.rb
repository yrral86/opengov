require 'mime/types'

class StaticController < Derailed::Component::Controller
  def javascript
    path = "#{Derailed::Config::RootDir}/javascript/#{next_path}"
    render_path path
  end

  def images
    path = "#{Derailed::Config::RootDir}/images/#{next_path}"
    render_path path
  end

  private
  def render_path(path)
    begin
      file = File.read path
      type = MIME::Types.of(path).first
      render_string file, {'Content-Type' => type.to_s}
    rescue
      not_found "Not found: #{full_path}"
    end
  end
end
