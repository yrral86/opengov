class MapController < Derailed::Component::Controller
  def index
    user = @component.current_user
    map = Map.find_or_create_by_user_id user[:id]
    render 'map', binding
  end

  def locations
    user = @component.current_user
    map = Map.find_or_create_by_user_id user[:id]
    objects = map.locations
    render 'locations', binding
  end
end
