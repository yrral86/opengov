class DebugController < Derailed::Component::Controller
  def test
    render_string "DebugController says hi!"
  end
end
