require 'rack'

class OpenGovRequestParser
  def initialize(env)
    @r = Rack::Request.new(env)
    @paths = @r.path.split '/'
    @paths.shift
  end

  def next
    @paths.shift
  end
end
