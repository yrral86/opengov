module Derailed
  module API
    module Manager
      include Base
      # information.rb
      def available_components; end
      def available_models; end
      def available_routes; end
      def available_types; end
      def check_key; end
      def components_with_type; end
      # components.rb
      def component_command; end
      def component_pid; end
      # registration.rb
      def register_component; end
      def unregister_component; end
      # allows fetching logger DRbObject
      def logger; end
    end
  end
end
