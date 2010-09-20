class MapController < Derailed::Component::Controller
  def index
    user = @component.current_user
    map = Map.find_or_create_by_user_id(user[:id], :include => :locations)
    render 'map', binding
  end
end
