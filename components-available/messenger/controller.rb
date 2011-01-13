class MessengerController < Derailed::Component::Controller
  def test_remote_foreign_key
    message = Message.find(:first)
    render_string message.sender.username
  end
end
